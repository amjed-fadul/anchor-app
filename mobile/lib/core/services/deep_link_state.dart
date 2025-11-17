/// Deep Link State
///
/// Represents the current state of deep link processing.
/// Used with StateNotifier to make HomeScreen reactive to incoming shares.
///
/// States:
/// - [DeepLinkInitial]: No pending deep links (default state)
/// - [DeepLinkUrlPending]: A shared URL is waiting to be processed

sealed class DeepLinkState {
  const DeepLinkState();
}

/// Initial state - no pending deep links
class DeepLinkInitial extends DeepLinkState {
  const DeepLinkInitial();
}

/// A shared URL is pending and needs to be processed
///
/// When this state is set, HomeScreen should:
/// 1. Read the [url]
/// 2. Show AddLinkFlowScreen with the URL
/// 3. Reset state back to [DeepLinkInitial]
class DeepLinkUrlPending extends DeepLinkState {
  final String url;

  const DeepLinkUrlPending(this.url);
}
