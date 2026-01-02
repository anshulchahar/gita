/// Generic Resource class for handling async operations
/// Similar to Kotlin's sealed class pattern
sealed class Resource<T> {
  const Resource();
}

class ResourceLoading<T> extends Resource<T> {
  const ResourceLoading();
}

class ResourceSuccess<T> extends Resource<T> {
  final T data;
  const ResourceSuccess(this.data);
}

class ResourceError<T> extends Resource<T> {
  final String message;
  final Exception? exception;
  const ResourceError(this.message, {this.exception});
}
