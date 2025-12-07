import 'dart:async';

/// A simple rate limiter that enforces a maximum number of requests per minute.
///
/// This is used to prevent exceeding Gemini API quota (15 RPM for free tier).
class RateLimiter {
  final int maxRequestsPerMinute;
  final List<DateTime> _requestTimestamps = [];

  RateLimiter({required this.maxRequestsPerMinute});

  /// Waits until a slot is available based on the rate limit.
  ///
  /// This method blocks until it's safe to make another request without
  /// exceeding the configured rate limit.
  Future<void> waitForSlot() async {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    // Remove timestamps older than 1 minute
    _requestTimestamps.removeWhere(
      (timestamp) => timestamp.isBefore(oneMinuteAgo),
    );

    // If we've hit the limit, wait until the oldest request expires
    if (_requestTimestamps.length >= maxRequestsPerMinute) {
      final oldestRequest = _requestTimestamps.first;
      final waitUntil = oldestRequest.add(const Duration(minutes: 1));
      final waitDuration = waitUntil.difference(now);

      if (waitDuration.isNegative) {
        // Should not happen due to removeWhere above, but just in case
        _requestTimestamps.removeAt(0);
      } else {
        await Future.delayed(waitDuration);
        // Remove the expired timestamp
        _requestTimestamps.removeAt(0);
      }
    }

    // Record this request
    _requestTimestamps.add(DateTime.now());
  }

  /// Resets the rate limiter state.
  void reset() {
    _requestTimestamps.clear();
  }
}
