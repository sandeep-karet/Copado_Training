/**
 * Created by jpatel on 4/25/19.
 */

public class MemberGroupTriggerHelper {
  public static Boolean isFirstTime = true;
  public static void setGUID(List<Mbr_Group__c> newMbrGroups) {
    for (Mbr_Group__c mbrGroup : newMbrGroups) {
      if (
        String.isBlank(mbrGroup.GUID__c) ||
        !GlobalIdUtils.isGuid(mbrGroup.GUID__c)
      ) {
        mbrGroup.GUID__c = GlobalIdUtils.generateGuid();
      }
    }
  }
  public static void checkLogo(List<Mbr_Group__c> newMbrGroups) {
  }
  public static void validateLogoUrls(
    List<Mbr_Group__c> newMbrGroups,
    Map<Id, Mbr_Group__c> oldMbrGroups
  ) {
    Set<String> logoNames = new Set<String>();
    logoNames.add('MK_TDH_HZ_2');
    system.debug(newMbrGroups);
    system.debug(oldMbrGroups);
    Boolean isCreate = false;
    if (oldMbrGroups == null) {
      isCreate = true;
    }
    String umrAcGUID = System.Label.umrAccountGUID;
    Account umrAcct = [SELECT Id FROM Account WHERE Guid__c = :umrAcGUID];
    if (newMbrGroups != null) {
      for (Mbr_Group__c mbrGroup : newMbrGroups) {
        Mbr_Group__c oldMbrGroup = new Mbr_Group__c();
        if (oldMbrGroups != null) {
          oldMbrGroup = oldMbrGroups.get(mbrGroup.id);
        } else {
          oldMbrGroup.Logo_Tag_ID__c = null;
          oldMbrGroup.Logo1_ID__c = null;
          oldMbrGroup.Logo2_ID__c = null;
          oldMbrGroup.Logo3_ID__c = null;
          oldMbrGroup.Logo4_ID__c = null;
          oldMbrGroup.AltLogo1_ID__c = null;
          oldMbrGroup.AltLogo2_ID__c = null;
        }

        if (
          mbrGroup.Logo_Tag_ID__c != null &&
          oldMbrGroup.Logo_Tag_ID__c != mbrGroup.Logo_Tag_ID__c
        ) {
          logoNames.add(mbrGroup.Logo_Tag_ID__c);
        }
        if (
          mbrGroup.Logo1_ID__c != null &&
          oldMbrGroup.Logo1_ID__c != mbrGroup.Logo1_ID__c
        ) {
          logoNames.add(mbrGroup.Logo1_ID__c);
        }
        if (
          mbrGroup.Logo2_ID__c != null &&
          oldMbrGroup.Logo2_ID__c != mbrGroup.Logo2_ID__c
        ) {
          logoNames.add(mbrGroup.Logo2_ID__c);
        }
        if (
          mbrGroup.Logo3_ID__c != null &&
          oldMbrGroup.Logo3_ID__c != mbrGroup.Logo3_ID__c
        ) {
          logoNames.add(mbrGroup.Logo3_ID__c);
        }
        if (
          mbrGroup.Logo4_ID__c != null &&
          oldMbrGroup.Logo4_ID__c != mbrGroup.Logo4_ID__c
        ) {
          logoNames.add(mbrGroup.Logo4_ID__c);
        }
        if (
          mbrGroup.AltLogo1_ID__c != null &&
          oldMbrGroup.AltLogo1_ID__c != mbrGroup.AltLogo1_ID__c
        ) {
          logoNames.add(mbrGroup.AltLogo1_ID__c);
        }
        if (
          mbrGroup.AltLogo2_ID__c != null &&
          oldMbrGroup.AltLogo2_ID__c != mbrGroup.AltLogo2_ID__c
        ) {
          logoNames.add(mbrGroup.AltLogo2_ID__c);
        }
      }
      Map<String, Document> docMap = new Map<String, Document>();
      Map<String, ContentVersion> cvMap = new Map<String, ContentVersion>();
      //system.debug([SELECT Id, Name FROM ContentWorkspace]);
      //ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0].Id;
	  ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'].isEmpty() ? 
                			 null 
                			: [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0].Id;
      logo_setting__c ls = logo_setting__c.getOrgDefaults();

      if (ls.isDocument__c) {
        for (Document d : [
          SELECT Id, Name
          FROM Document
          WHERE Name IN :logoNames
        ]) {
          docMap.put(d.Name, d);
        }
        for (Mbr_Group__c mbrGroup : newMbrGroups) {
          Mbr_Group__c oldMbrGroup = new Mbr_Group__c();
          if (oldMbrGroups != null) {
            oldMbrGroup = oldMbrGroups.get(mbrGroup.id);
          } else {
            oldMbrGroup.Logo_Tag_ID__c = null;
            oldMbrGroup.Logo1_ID__c = null;
            oldMbrGroup.Logo2_ID__c = null;
            oldMbrGroup.Logo3_ID__c = null;
            oldMbrGroup.Logo4_ID__c = null;
            oldMbrGroup.AltLogo1_ID__c = null;
            oldMbrGroup.AltLogo2_ID__c = null;
          }

          if (mbrGroup.Logo_Tag_ID__c == null) {
            mbrGroup.Logo__c = null;
          } else if (oldMbrGroup.Logo_Tag_ID__c != mbrGroup.Logo_Tag_ID__c) {
            if (docMap.get(mbrGroup.Logo_Tag_ID__c) != null) {
              mbrGroup.Logo__c = genLogoUrl(
                docMap.get(mbrGroup.Logo_Tag_ID__c).id
              );
            } else {
              mbrGroup.Logo_Tag_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.Logo1_ID__c == null) {
            if (
              isCreate &&
              umrAcct != null &&
              mbrGroup.Client_Account__c == umrAcct.Id
            ) {
              mbrGroup.Logo1_ID__c = 'MK_TDH_HZ_2';
              mbrGroup.Logo1__c = genLogoUrl(
                docMap.get(mbrGroup.Logo1_ID__c).id
              );
            } else {
              mbrGroup.Logo1__c = null;
            }
          } else if (oldMbrGroup.Logo1_ID__c != mbrGroup.Logo1_ID__c) {
            if (docMap.get(mbrGroup.Logo1_ID__c) != null) {
              mbrGroup.Logo1__c = genLogoUrl(
                docMap.get(mbrGroup.Logo1_ID__c).id
              );
            } else {
              mbrGroup.Logo1_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.Logo2_ID__c == null) {
            mbrGroup.Logo2__c = null;
          } else if (oldMbrGroup.Logo2_ID__c != mbrGroup.Logo2_ID__c) {
            if (docMap.get(mbrGroup.Logo2_ID__c) != null) {
              mbrGroup.Logo2__c = genLogoUrl(
                docMap.get(mbrGroup.Logo2_ID__c).id
              );
            } else {
              mbrGroup.Logo2_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.Logo3_ID__c == null) {
            mbrGroup.Logo3__c = null;
          } else if (oldMbrGroup.Logo3_ID__c != mbrGroup.Logo3_ID__c) {
            if (docMap.get(mbrGroup.Logo3_ID__c) != null) {
              mbrGroup.Logo3__c = genLogoUrl(
                docMap.get(mbrGroup.Logo3_ID__c).id
              );
            } else {
              mbrGroup.Logo3_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.Logo4_ID__c == null) {
            mbrGroup.Logo4__c = null;
          } else if (oldMbrGroup.Logo4_ID__c != mbrGroup.Logo4_ID__c) {
            if (docMap.get(mbrGroup.Logo4_ID__c) != null) {
              mbrGroup.Logo4__c = genLogoUrl(
                docMap.get(mbrGroup.Logo4_ID__c).id
              );
            } else {
              mbrGroup.Logo4_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.AltLogo1_ID__c == null) {
            mbrGroup.AltLogo1__c = null;
          } else if (oldMbrGroup.AltLogo1_ID__c != mbrGroup.AltLogo1_ID__c) {
            if (docMap.get(mbrGroup.AltLogo1_ID__c) != null) {
              mbrGroup.AltLogo1__c = genLogoUrl(
                docMap.get(mbrGroup.AltLogo1_ID__c).id
              );
            } else {
              mbrGroup.AltLogo1_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.AltLogo2_ID__c == null) {
            mbrGroup.AltLogo2__c = null;
          } else if (oldMbrGroup.AltLogo2_ID__c != mbrGroup.AltLogo2_ID__c) {
            if (docMap.get(mbrGroup.AltLogo2_ID__c) != null) {
              mbrGroup.AltLogo2__c = genLogoUrl(
                docMap.get(mbrGroup.AltLogo2_ID__c).id
              );
            } else {
              mbrGroup.AltLogo2_ID__c.addError('Invalid Document Name');
            }
          }
        }
      } else {
        for (ContentVersion cv : [
          SELECT ContentDocument.Id, Title
          FROM ContentVersion USING SCOPE EVERYTHING
          WHERE ContentDocument.ParentId = :workspaceId AND Title IN :logoNames
        ]) {
          cvMap.put(cv.Title, cv);
        }
        for (Mbr_Group__c mbrGroup : newMbrGroups) {
          Mbr_Group__c oldMbrGroup = new Mbr_Group__c();
          if (oldMbrGroups != null) {
            oldMbrGroup = oldMbrGroups.get(mbrGroup.id);
          } else {
            oldMbrGroup.Logo_Tag_ID__c = null;
            oldMbrGroup.Logo1_ID__c = null;
            oldMbrGroup.Logo2_ID__c = null;
            oldMbrGroup.Logo3_ID__c = null;
            oldMbrGroup.Logo4_ID__c = null;
            oldMbrGroup.AltLogo1_ID__c = null;
            oldMbrGroup.AltLogo2_ID__c = null;
          }

          if (mbrGroup.Logo_Tag_ID__c == null) {
            mbrGroup.Logo__c = null;
          } else if (oldMbrGroup.Logo_Tag_ID__c != mbrGroup.Logo_Tag_ID__c) {
            if (cvMap.get(mbrGroup.Logo_Tag_ID__c) != null) {
              mbrGroup.Logo__c = genLogoFile(
                cvMap.get(mbrGroup.Logo_Tag_ID__c).ContentDocument.id
              );
            } else {
              mbrGroup.Logo_Tag_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.Logo1_ID__c == null) {
            if (
              isCreate &&
              umrAcct != null &&
              mbrGroup.Client_Account__c == umrAcct.Id
            ) {
              mbrGroup.Logo1_ID__c = 'MK_TDH_HZ_2';
              system.debug(mbrGroup.Logo1_ID__c);
              system.debug(cvMap);
              mbrGroup.Logo1__c = genLogoFile(
                cvMap.get(mbrGroup.Logo1_ID__c).ContentDocument.id
              );
            } else {
              mbrGroup.Logo1__c = null;
            }
          } else if (oldMbrGroup.Logo1_ID__c != mbrGroup.Logo1_ID__c) {
            if (cvMap.get(mbrGroup.Logo1_ID__c) != null) {
              mbrGroup.Logo1__c = genLogoFile(
                cvMap.get(mbrGroup.Logo1_ID__c).ContentDocument.id
              );
            } else {
              mbrGroup.Logo1_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.Logo2_ID__c == null) {
            mbrGroup.Logo2__c = null;
          } else if (oldMbrGroup.Logo2_ID__c != mbrGroup.Logo2_ID__c) {
            if (cvMap.get(mbrGroup.Logo2_ID__c) != null) {
              mbrGroup.Logo2__c = genLogoFile(
                cvMap.get(mbrGroup.Logo2_ID__c).ContentDocument.id
              );
            } else {
              mbrGroup.Logo2_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.Logo3_ID__c == null) {
            mbrGroup.Logo3__c = null;
          } else if (oldMbrGroup.Logo3_ID__c != mbrGroup.Logo3_ID__c) {
            if (cvMap.get(mbrGroup.Logo3_ID__c) != null) {
              mbrGroup.Logo3__c = genLogoFile(
                cvMap.get(mbrGroup.Logo3_ID__c).ContentDocument.id
              );
            } else {
              mbrGroup.Logo3_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.Logo4_ID__c == null) {
            mbrGroup.Logo4__c = null;
          } else if (oldMbrGroup.Logo4_ID__c != mbrGroup.Logo4_ID__c) {
            if (cvMap.get(mbrGroup.Logo4_ID__c) != null) {
              mbrGroup.Logo4__c = genLogoFile(
                cvMap.get(mbrGroup.Logo4_ID__c).ContentDocument.id
              );
            } else {
              mbrGroup.Logo4_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.AltLogo1_ID__c == null) {
            mbrGroup.AltLogo1__c = null;
          } else if (oldMbrGroup.AltLogo1_ID__c != mbrGroup.AltLogo1_ID__c) {
            if (cvMap.get(mbrGroup.AltLogo1_ID__c) != null) {
              mbrGroup.AltLogo1__c = genLogoFile(
                cvMap.get(mbrGroup.AltLogo1_ID__c).ContentDocument.id
              );
            } else {
              mbrGroup.AltLogo1_ID__c.addError('Invalid Document Name');
            }
          }

          if (mbrGroup.AltLogo2_ID__c == null) {
            mbrGroup.AltLogo2__c = null;
          } else if (oldMbrGroup.AltLogo2_ID__c != mbrGroup.AltLogo2_ID__c) {
            if (cvMap.get(mbrGroup.AltLogo2_ID__c) != null) {
              mbrGroup.AltLogo2__c = genLogoFile(
                cvMap.get(mbrGroup.AltLogo2_ID__c).ContentDocument.id
              );
            } else {
              mbrGroup.AltLogo2_ID__c.addError('Invalid Document Name');
            }
          }
        }
      }
    }
  }

  private static String genLogoUrl(Id docId) {
    // width of image is reduced, but original image is not lost, for download, etc.
    return '<img src=\'/servlet/servlet.ImageServer?id=' +
      docId +
      '&oid=' +
      UserInfo.getOrganizationId() +
      '\' width="28%"/>';
  }

  private static String genLogoFile(Id fileId) {
    return '<img src=\'/sfc/servlet.shepherd/document/download/' +
      fileId +
      '\' width="28%"/>';
  }

  //Method to Auto-create Member Group Role of billing role type upon Member Group creation
  public static void createMemberGroupRole(List<Mbr_Group__c> newMbrGroups) {
    List<Mbr_Group_Role__c> memberGrpRole = new List<Mbr_Group_Role__c>();

    for (Mbr_Group__c memGrp : newMbrGroups) {
      if (memGrp.Client_Account__c != null) {
        Mbr_Group_Role__c memGrpRole = new Mbr_Group_Role__c();
        memGrpRole.Mbr_Group__c = memGrp.Id;
        memGrpRole.Source_Account__c = memGrp.Client_Account__c;
        memGrpRole.Role_Type__c = 'Billing';
        memberGrpRole.add(memGrpRole);
      }
    }

    if (!memberGrpRole.isEmpty()) {
      insert memberGrpRole;
    }
  }

  //Method to auto-populate field values
  public static void autopopulatefieldvalues(
    List<Mbr_Group__c> newMbrGroups,
    Map<Id, Mbr_Group__c> oldMbrGroups
  ) {
    set<ID> clientAccountIds = new Set<ID>();
    for (Mbr_Group__c mbr : newMbrGroups) {
      if (null == mbr.Card_Name__c)
        clientAccountIds.add(mbr.Client_Account__c);
    }
    Map<Id, Account> accountMap = new Map<Id, Account>(
      [SELECT Id, name FROM Account WHERE id IN :clientAccountIds]
    );
    for (Mbr_Group__c mbr : newMbrGroups) {
      mbr.Card_Name__c = null != mbr.Card_Name__c
        ? mbr.Card_Name__c
        : accountMap.get(mbr.Client_Account__c).Name;
        
        Boolean shouldUpdateHealthAssistant = Trigger.isInsert;
         if (Trigger.isUpdate && oldMbrGroups != null) {
            Mbr_Group__c oldMbr = oldMbrGroups.get(mbr.Id);
            shouldUpdateHealthAssistant = oldMbr.OneAppAccess__c != mbr.OneAppAccess__c;
        }
         if (shouldUpdateHealthAssistant) {
            mbr.Health_Assistant__c = (mbr.OneAppAccess__c == 'Yes');
        }
        
    }
  }
}