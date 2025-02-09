import 'package:flutter/material.dart';

class LoadingState<T> {
  final T? data;
  final bool isLoading;
  final String? error;

  const LoadingState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  factory LoadingState.loading() => LoadingState(isLoading: true);
  factory LoadingState.error(String message) => LoadingState(error: message);
  factory LoadingState.data(T data) => LoadingState(data: data);

  bool get hasData => data != null;
  bool get hasError => error != null;

  LoadingState<T> copyWith({
    T? data,
    bool? isLoading,
    String? error,
  }) {
    return LoadingState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LoadingStateWidget<T> extends StatelessWidget {
  final LoadingState<T> state;
  final Widget Function(T data) onData;
  final Widget Function(String error)? onError;
  final Widget? loadingWidget;

  const LoadingStateWidget({
    super.key,
    required this.state,
    required this.onData,
    this.onError,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return onError?.call(state.error!) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
    }

    if (!state.hasData) {
      return const Center(child: Text('No data available'));
    }

    return onData(state.data as T);
  }
}
