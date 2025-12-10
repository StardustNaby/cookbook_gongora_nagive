/// Helper class para manejar URLs de imágenes, especialmente de Google Images
class ImageHelper {
  /// Limpia y normaliza URLs de imágenes de Google
  /// 
  /// Las URLs de Google Images suelen venir en formato:
  /// https://www.google.com/imgres?imgurl=ACTUAL_URL&imgrefurl=...
  /// 
  /// Este método extrae la URL real de la imagen.
  static String? cleanImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Si es una URL de Google Share (share.google), no es una URL directa de imagen
    // Estas URLs requieren autenticación y no funcionan directamente
    if (url.contains('share.google')) {
      // Intentar convertir a URL de Google Drive si es posible
      // Pero generalmente estas URLs no funcionan como imágenes directas
      return null; // Retornar null para que se muestre el placeholder
    }
    
    // Si es una URL de Google Images, extraer la URL real
    if (url.contains('google.com/imgres')) {
      final uri = Uri.parse(url);
      final imgUrl = uri.queryParameters['imgurl'];
      if (imgUrl != null && imgUrl.isNotEmpty) {
        return Uri.decodeComponent(imgUrl);
      }
    }
    
    // Si es una URL de Google que contiene "url=", extraerla
    if (url.contains('google.com') && url.contains('url=')) {
      final uri = Uri.parse(url);
      final imageUrl = uri.queryParameters['url'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return Uri.decodeComponent(imageUrl);
      }
    }
    
    // Validar que sea una URL válida
    try {
      final uri = Uri.parse(url);
      if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return url;
      }
    } catch (e) {
      return null;
    }
    
    return url;
  }
  
  /// Valida si una URL es válida para cargar imágenes
  /// Ahora es más permisiva - solo verifica que sea una URL HTTP/HTTPS válida
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    final cleanedUrl = cleanImageUrl(url);
    if (cleanedUrl == null) return false;
    
    try {
      final uri = Uri.parse(cleanedUrl);
      // Solo verificar que tenga scheme HTTP/HTTPS y un host válido
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }
      
      // Si tiene un host válido, es suficiente
      // No requerimos extensión de imagen porque muchas APIs no la tienen
      return uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene headers HTTP para cargar imágenes
  /// Algunos servidores requieren headers específicos para evitar bloqueos
  static Map<String, String> getImageHeaders(String? url) {
    final headers = <String, String>{
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'Referer': 'https://www.google.com/',
    };
    
    // Si es una URL de Google, agregar headers adicionales
    if (url != null && url.contains('google.com')) {
      headers['Referer'] = 'https://www.google.com/';
    }
    
    return headers;
  }
}

