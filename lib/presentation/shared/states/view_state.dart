enum ViewStatus { idle, loading, success, error }

class ViewState<T> {
  const ViewState({this.status = ViewStatus.idle, this.data, this.message});

  final ViewStatus status;
  final T? data;
  final String? message;

  ViewState<T> copyWith({ViewStatus? status, T? data, String? message}) {
    return ViewState<T>(status: status ?? this.status, data: data ?? this.data, message: message ?? this.message);
  }
}
