// lib/photo_manager.dart
// WreckLog photo UI — PhotoStrip + fullscreen viewer.
// No dart:io here. Platform storage handled via photo_storage.dart.
// FileImage handled via photo_file_image.dart conditional import.

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

// Conditional imports — each file exports the same API
import 'photo_constants.dart';                                      // kMaxPhotosPerOwner
import 'photo_storage.dart';                                        // AppPhoto + PhotoStorage
import 'photo_file_image.dart'; // conditional router → io or stub

export 'photo_storage.dart'; // re-export so callers get AppPhoto

// ── Constants ────────────────────────────────────────────────────────────────
// kMaxPhotosPerOwner is defined in photo_constants.dart
const int kMaxVehiclePhotos = kMaxPhotosPerOwner;
const int kMaxPartPhotos    = kMaxPhotosPerOwner;

// ── Image provider helper ─────────────────────────────────────────────────────
ImageProvider _imageProviderFor(AppPhoto photo) {
  if (kIsWeb) {
    return MemoryImage(base64Decode(photo.pathOrData));
  }
  return photoFileImage(photo.pathOrData);
}

// ── PhotoStrip ────────────────────────────────────────────────────────────────
class PhotoStrip extends StatefulWidget {
  final String ownerType; // "vehicle" or "part"
  final String ownerId;
  final int maxCount;

  const PhotoStrip({
    super.key,
    required this.ownerType,
    required this.ownerId,
    required this.maxCount,
  });

  @override
  State<PhotoStrip> createState() => _PhotoStripState();
}

class _PhotoStripState extends State<PhotoStrip> {
  List<AppPhoto> _photos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final photos = await PhotoStorage.forOwner(widget.ownerType, widget.ownerId);
    if (mounted) setState(() { _photos = photos; _loading = false; });
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= widget.maxCount) { _showMaxSnackbar(); return; }
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 85, maxWidth: 1280, maxHeight: 1280,
      );
      if (picked == null || !mounted) return;
      if (_photos.length >= widget.maxCount) { _showMaxSnackbar(); return; }

      // addFromXFile works on all platforms:
      // iOS/Android → delegates to add(sourcePath: xfile.path)
      // Web         → reads bytes, stores as base64
      final photo = await PhotoStorage.addFromXFile(
        ownerType: widget.ownerType,
        ownerId:   widget.ownerId,
        xfile:     picked,
      );
      if (mounted) setState(() => _photos.add(photo));

      // Auto-save to device gallery (mobile only) — silent fail so a
      // permissions denial doesn't block the user from using the photo.
      if (!kIsWeb) {
        try { await Gal.putImage(photo.pathOrData, album: 'WreckLog'); } catch (_) {}
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add photo: $e')));
    }
  }

  Future<void> _pickMultiple() async {
    final remaining = widget.maxCount - _photos.length;
    if (remaining <= 0) { _showMaxSnackbar(); return; }
    try {
      final picked = await ImagePicker().pickMultiImage(
        imageQuality: 85, maxWidth: 1280, maxHeight: 1280,
      );
      if (picked.isEmpty || !mounted) return;

      // Only import up to the remaining slots
      final toImport = picked.take(remaining).toList();
      final added = <AppPhoto>[];

      for (final xfile in toImport) {
        final photo = await PhotoStorage.addFromXFile(
          ownerType: widget.ownerType,
          ownerId:   widget.ownerId,
          xfile:     xfile,
        );
        added.add(photo);
        // Auto-save each to gallery
        if (!kIsWeb) {
          try { await Gal.putImage(photo.pathOrData, album: 'WreckLog'); } catch (_) {}
        }
      }

      if (mounted) setState(() => _photos.addAll(added));

      // Let user know if we had to cap the import
      if (picked.length > remaining && mounted) {
        final label = widget.ownerType == 'vehicle' ? 'vehicle' : 'part';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Added $remaining photo${remaining == 1 ? '' : 's'} — max ${widget.maxCount} per $label reached.'),
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add photos: $e')));
    }
  }

  void _showMaxSnackbar() {
    final label = widget.ownerType == 'vehicle' ? 'vehicle' : 'part';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Max ${widget.maxCount} photos per $label')));
  }

  Future<void> _delete(AppPhoto photo) async {
    await PhotoStorage.delete(photo);
    if (mounted) setState(() => _photos.remove(photo));
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context, useSafeArea: true,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () { Navigator.pop(context); _pickPhoto(); },
            ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            subtitle: Text('Select up to ${widget.maxCount} photos'),
            onTap: () { Navigator.pop(context); _pickMultiple(); },
          ),
        ]),
      ),
    );
  }

  void _openFullscreen(int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullscreenViewer(
        photos: _photos, initialIndex: index, onDelete: _delete,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isFull = _photos.length >= widget.maxCount;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFFE8700A)),
        const SizedBox(width: 6),
        Text('Photos (${_photos.length}/${widget.maxCount})',
          style: const TextStyle(color: Color(0xFFE8700A), fontWeight: FontWeight.w700, fontSize: 13)),
        const Spacer(),
        TextButton.icon(
          onPressed: isFull ? null : _showPicker,
          icon: const Icon(Icons.add_a_photo_outlined, size: 16),
          label: const Text('Add'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            foregroundColor: isFull ? Colors.white24 : const Color(0xFFE8700A),
          ),
        ),
      ]),
      // On-device notice — subtle, honest, one line
      if (!kIsWeb)
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Icon(Icons.photo_library_outlined, size: 11, color: Colors.white24),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                'Saved in-app. Also saves to your gallery if permission is granted.',
                style: TextStyle(fontSize: 11, color: Colors.white24),
              ),
            ),
          ]),
        ),
      const SizedBox(height: 8),
      if (_loading)
        const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
      else if (_photos.isEmpty)
        GestureDetector(
          onTap: _showPicker,
          child: Container(
            height: 72, width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_a_photo_outlined, color: Colors.white24, size: 20),
              SizedBox(width: 8),
              Text('Tap to add photos', style: TextStyle(color: Colors.white24, fontSize: 13)),
            ]),
          ),
        )
      else
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _Thumbnail(
              photo: _photos[i],
              onTap: () => _openFullscreen(i),
              onDelete: () => _delete(_photos[i]),
            ),
          ),
        ),
    ]);
  }
}

// ── Thumbnail ─────────────────────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final AppPhoto photo;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _Thumbnail({required this.photo, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _confirmDelete(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(children: [
          SizedBox(
            width: 90, height: 90,
            child: Image(
              image: _imageProviderFor(photo),
              fit: BoxFit.cover, width: 90, height: 90,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white10,
                child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white24)),
              ),
            ),
          ),
          Positioned(
            top: 2, right: 2,
            child: GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete photo?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((ok) { if (ok == true) onDelete(); });
  }
}

// ── Fullscreen viewer ─────────────────────────────────────────────────────────
class _FullscreenViewer extends StatefulWidget {
  final List<AppPhoto> photos;
  final int initialIndex;
  final Future<void> Function(AppPhoto) onDelete;
  const _FullscreenViewer({required this.photos, required this.initialIndex, required this.onDelete});

  @override
  State<_FullscreenViewer> createState() => _FullscreenViewerState();
}

class _FullscreenViewerState extends State<_FullscreenViewer> {
  late List<AppPhoto> _photos;
  late PageController _pageCtrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.photos);
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: _current);
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  Future<void> _delete() async {
    final photo = _photos[_current];
    await widget.onDelete(photo);
    if (_photos.length == 1) { if (mounted) Navigator.of(context).pop(); return; }
    setState(() {
      _photos.removeAt(_current);
      if (_current >= _photos.length) _current = _photos.length - 1;
    });
    _pageCtrl.jumpToPage(_current);
  }

  Future<void> _share() async {
    final photo = _photos[_current];
    try {
      if (kIsWeb) {
        // Web — decode base64 to bytes and share as XFile
        final bytes = base64Decode(photo.pathOrData);
        final xfile = XFile.fromData(bytes, mimeType: 'image/jpeg', name: '${photo.id}.jpg');
        await Share.shareXFiles([xfile], text: 'WreckLog photo');
      } else {
        // Mobile — share the file directly
        await Share.shareXFiles([XFile(photo.pathOrData)], text: 'WreckLog photo');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not share photo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${_photos.length}', style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            tooltip: 'Share photo',
            onPressed: _share,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete photo',
            onPressed: _delete,
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageCtrl,
        itemCount: _photos.length,
        onPageChanged: (i) => setState(() => _current = i),
        builder: (_, i) {
          ImageProvider? provider;
          try { provider = _imageProviderFor(_photos[i]); } catch (_) {}

          if (provider == null) {
            return PhotoViewGalleryPageOptions.customChild(
              child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.broken_image_outlined, color: Colors.white24, size: 48),
                SizedBox(height: 8),
                Text('Photo file missing', style: TextStyle(color: Colors.white38)),
              ])),
            );
          }
          return PhotoViewGalleryPageOptions(
            imageProvider: provider,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 48)),
          );
        },
      ),
    );
  }
}
