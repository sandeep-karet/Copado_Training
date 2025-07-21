/**
 * @author Wenbo Zhou
 * @date 2021-05-16
 *
 * @description This class manages the trigger configuration metadata based on the currently SObject trigger context
 *
 *  * Originally from github.com/trailheadapps/apex-recipes
 **/

public with sharing class SDF_TGF_MetadataTriggerService {

    /**
     * @description Default exception class
     */
    public class MetadataTriggerServiceException extends Exception {
    }

    private String objType = '';

    /**
     * @description Creates a metadata trigger service object with an SObject type name
     * @param objectTypeName SObject type name for which the service should get the handlers
     */
    public SDF_TGF_MetadataTriggerService(String objectTypeName) {
        this.objType = objectTypeName;
    }

    /**
     * @description This query finds an ordered list trigger handler classes
     * to execute. It ignores any classes that are marked as disabled.
     *
     * Note: It will exclude any triggerHandler metadata records for which
     * the user's email address is found in a related disabled_for__mdt
     * record.
     *
     * Admin's and Developers can selectively disable trigger handlers
     * for all or selected individuals *without* deploying.
     * @return A list of SDF_TGF_Trigger_Config__mdt trigger configuration metadata
     */
    public List<SDF_TGF_Trigger_Config__mdt> getMetadataTriggers() {
        return [
            SELECT Class__c, Order__c
            FROM SDF_TGF_Trigger_Config__mdt
            WHERE
            Object__c = :this.objType
            AND Enabled__c = TRUE
            ORDER BY Order__c
        ];
    }

    /**
     * @description This determines the active sObject type by describing the first
     * record in the trigger New / Old list
     * @return the string name of the SObject type
     */
    @SuppressWarnings('PMD.AvoidDirectAccessTriggerMap')
    public static String getSObjectType() {
        if (Trigger.new != null) {
            return Trigger.new[0].getSObjectType().getDescribe().getName();
        } else if (Trigger.old != null) {
            return Trigger.old[0].getSObjectType().getDescribe().getName();
        }
        throw new MetadataTriggerServiceException(
            'Trigger.new && Trigger.old are both null. Are you excercising this method outside of a trigger context?'
        );
    }
}