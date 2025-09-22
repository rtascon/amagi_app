/// Utilidad para obtener la extensión de archivo a partir del tipo MIME.
String? extensionFromMime(String mimeType) {
  final map = <String, String>{
    'application/pdf': 'pdf',
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/gif': 'gif',
    'image/bmp': 'bmp',
    'image/webp': 'webp',
    'text/plain': 'txt',
    'application/msword': 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        'docx',
    'application/vnd.ms-excel': 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
    'application/vnd.ms-powerpoint': 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        'pptx',
    'application/zip': 'zip',
    'application/x-rar-compressed': 'rar',
    'application/json': 'json',
    'application/xml': 'xml',
    'application/octet-stream': 'bin',
  };
  return map[mimeType];
}
