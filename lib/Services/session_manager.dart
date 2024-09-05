class SessionManager{
  static final SessionManager _session= SessionManager._internal();
  String ?userid;
  factory SessionManager(){
    return _session;
  }
  SessionManager._internal(){}
}