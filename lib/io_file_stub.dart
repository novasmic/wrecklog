// lib/io_file_stub.dart
// Web stub — dart:io is unavailable on web; File and Directory are never
// called at runtime because all IO paths are guarded by kIsWeb checks.

class File {
  File(String path);
  Future<bool> exists() async => false;
  Future<File> copy(String newPath) async => this;
  Future<File> delete() async => this;
  Future<File> rename(String newPath) async => this;
  Future<File> writeAsString(String contents) async => this;
  Future<File> writeAsBytes(List<int> bytes) async => this;
  Future<List<int>> readAsBytes() async => [];
  bool existsSync() => false;
  void deleteSync() {}
  String get path => '';
}

class Directory {
  Directory(String path);
  Future<Directory> create({bool recursive = false}) async => this;
  bool existsSync() => false;
  String get path => '';
}
