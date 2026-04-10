abstract final class RouteNames {
  static const coaches = 'coaches';
  static const history = 'history';
  static const newChat = 'new-chat';
  static const resumeChat = 'resume-chat';
}

abstract final class RoutePaths {
  static const coaches = '/coaches';
  static const history = '/history';
  static const newChat = '/chat/:coachId';
  static const resumeChat = '/session/:sessionId';

  static String newChatPath(String coachId) => '/chat/$coachId';
  static String resumeChatPath(String sessionId) => '/session/$sessionId';
}
