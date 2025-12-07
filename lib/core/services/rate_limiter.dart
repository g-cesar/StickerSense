import 'dart:async';

/// A simple rate limiter that enforces a maximum number of requests per minute and per day.
///
/// This is used to prevent exceeding Gemma API quota (30 RPM for free tier).
class RateLimiter {
  final int maxRequestsPerMinute;
  final int maxRequestsPerDay;
  final List<DateTime> _requestTimestamps = [];
  final List<DateTime> _dailyRequestTimestamps = [];

  RateLimiter({
    required this.maxRequestsPerMinute,
    this.maxRequestsPerDay = 20, // Default: 20 requests per day
  });

  /// Waits until a slot is available based on the rate limit.
  ///
  /// This method blocks until it's safe to make another request without
  /// exceeding the configured rate limits (both per-minute and per-day).
  Future<void> waitForSlot() async {
    final now = DateTime.now();

    // Check daily limit first
    await _checkDailyLimit(now);

    // Then check per-minute limit
    await _checkMinuteLimit(now);

    // Record this request
    _requestTimestamps.add(now);
    _dailyRequestTimestamps.add(now);
  }

  Future<void> _checkDailyLimit(DateTime now) async {
    final oneDayAgo = now.subtract(const Duration(days: 1));

    // Remove timestamps older than 1 day
    _dailyRequestTimestamps.removeWhere(
      (timestamp) => timestamp.isBefore(oneDayAgo),
    );

    // If we've hit the daily limit, wait until the oldest request expires
    if (_dailyRequestTimestamps.length >= maxRequestsPerDay) {
      final oldestRequest = _dailyRequestTimestamps.first;
      final waitUntil = oldestRequest.add(const Duration(days: 1));
      final waitDuration = waitUntil.difference(now);

      if (!waitDuration.isNegative) {
        await Future.delayed(waitDuration);
        _dailyRequestTimestamps.removeAt(0);
      } else {
        _dailyRequestTimestamps.removeAt(0);
      }
    }
  }

  Future<void> _checkMinuteLimit(DateTime now) async {
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

      if (!waitDuration.isNegative) {
        await Future.delayed(waitDuration);
        _requestTimestamps.removeAt(0);
      } else {
        _requestTimestamps.removeAt(0);
      }
    }
  }

  /// Resets the rate limiter state.
  void reset() {
    _requestTimestamps.clear();
    _dailyRequestTimestamps.clear();
  }
}
