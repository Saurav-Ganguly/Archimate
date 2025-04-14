/// A utility class to handle success and error cases in a type-safe way
class Result<T> {
  final T? _data;
  final Object? _error;
  final bool _isSuccess;

  const Result._({
    T? data,
    Object? error,
    required bool isSuccess,
  })  : _data = data,
        _error = error,
        _isSuccess = isSuccess;

  /// Creates a success result with the given data
  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  /// Creates an error result with the given error
  factory Result.error(Object error) {
    return Result._(error: error, isSuccess: false);
  }

  /// Whether this result is a success
  bool get isSuccess => _isSuccess;

  /// Whether this result is an error
  bool get isError => !_isSuccess;

  /// The data of this result, or null if it's an error
  T? get data => _isSuccess ? _data : null;

  /// The error of this result, or null if it's a success
  Object? get error => _isSuccess ? null : _error;

  /// Executes one of the given callbacks based on whether this result is a success or an error
  R when<R>({
    required R Function(T) onSuccess,
    required R Function(Object) onError,
  }) {
    if (_isSuccess) {
      return onSuccess(_data as T);
    } else {
      return onError(_error!);
    }
  }

  /// Maps the data of this result to a new type if it's a success
  Result<R> map<R>(R Function(T) mapper) {
    if (_isSuccess) {
      return Result.success(mapper(_data as T));
    } else {
      return Result.error(_error!);
    }
  }

  /// Returns the data of this result if it's a success, or the given fallback value if it's an error
  T getOrElse(T fallback) {
    return _isSuccess ? (_data as T) : fallback;
  }
}
