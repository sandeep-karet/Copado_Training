public class FreezeUsers {
    public static void Freeze() {
        Map<Id, User> mappedUsers = new Map<Id, User>([select id 
                                                       from user 
                                                       where profile.name != 'System Administrator' 
                                                       and isActive = true]);
        List<UserLogin> scopedLogins = [select id, isFrozen 
                                        from UserLogin 
                                        where userid in :mappedUsers.keyset()];
        System.debug(scopedLogins.size());
        for(UserLogin tmpUl : scopedLogins)
            tmpUl.isFrozen = true;
        if(!scopedLogins.isEmpty() && !Test.isRunningTest()) {  update scopedLogins; }
    }
    public static void Thaw() {
        List<UserLogin> scopedLogins = [select id, isFrozen 
                                        from UserLogin 
                                        where isFrozen = true];
        System.debug(scopedLogins.size());
        for(UserLogin tmpUl : scopedLogins)
            tmpUl.isFrozen = false;
        if(!scopedLogins.isEmpty() && !Test.isRunningTest()) {  update scopedLogins; }
    }
    
    public static void FreezeNonApi() {
        Map<Id, User> mappedUsers = new Map<Id, User>([select id 
                                                       from user 
                                                       where (profile.name != 'System Administrator' OR profile.name != 'Integration User Read Only' OR profile.name != 'Integration')
                                                       and isActive = true]);
        List<UserLogin> scopedLogins = [select id, isFrozen 
                                        from UserLogin 
                                        where userid in :mappedUsers.keyset()];
        System.debug(scopedLogins.size());
        for(UserLogin tmpUl : scopedLogins)
            tmpUl.isFrozen = true;
        if(!scopedLogins.isEmpty() && !Test.isRunningTest()) {   update scopedLogins; }
    }
}