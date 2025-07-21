public with sharing class TDAuthResponse {
  public Integer response_code;
  public Integer person_id;
  public String authentication_token;
  public String domain;
  public String temp_password_flg;
  public String reset_password_flg;
  public String auth_token;
  public String last_login_dt;
  public String last_login_date;
  public Integer domain_id;
  public List<String> errors;
  public List<String> roles;
}