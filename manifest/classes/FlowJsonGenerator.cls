public class FlowJsonGenerator {
  public static string generateJSONContent(MwResponseShape tmpMrs) {
    JSONGenerator gen = JSON.createGenerator(false);

    gen.writeStartObject();
    if (tmpMrs.contractee != null)
      gen.writeObjectField('contractee', tmpMrs.contractee);
    else
      gen.writeNullField('contractee');

    if (tmpMrs.bsp != null)
      gen.writeObjectField('bsp', tmpMrs.bsp);
    else
      gen.writeNullField('bsp');

    if (tmpMrs.payer != null)
      gen.writeObjectField('payer', tmpMrs.payer);
    else
      gen.writeNullField('payer');

    if (tmpMrs.contractee_rel != null)
      gen.writeObjectField('contractee_rel', tmpMrs.contractee_rel);
    else
      gen.writeNullField('contractee__rel');

    gen.writeObjectField('contracts', tmpMrs.contracts);
    gen.writeObjectField('brokers', tmpMrs.brokers);

    if (tmpMrs.member_group != null)
      gen.writeObjectField('member_group', tmpMrs.member_group);
    else
      gen.writeNullField('member_group');

    gen.writeObjectField('subscriptions', tmpMrs.subscriptions);

    // iterate through each psf if bd/emo combo exist otherwise serialize what we have
    if (tmpMrs.psf_bd_emp == null && tmpMrs.psf_emo == null)
      gen.writeObjectField('psfs', tmpMrs.psfs);
    else {
      gen.writeFieldName('psfs');
      gen.writeStartArray();
      for (Plan_Specific_Fees__c tmpPsf : tmpMrs.psfs) {
        if (tmpPsf.Id != tmpMrs.psf_emo.Id) {
          gen.writeObject(tmpPsf);
        } else {
          Map<String, Object> emoMap = tmpPsf.clone(true, true)
            .getPopulatedFieldsAsMap();
          gen.writeStartObject();
          for (String tmpFieldName : emoMap.keyset()) {
            if (tmpFieldName == 'Current_Membership_Fee__c')
              gen.writeObjectField(
                tmpFieldName,
                tmpMrs.psf_bd_emp.Current_Membership_Fee__c
              );
            else
              gen.writeObjectField(tmpFieldName, emoMap.get(tmpFieldName));
          }
          gen.writeEndObject();
        }
      }
      gen.writeEndArray();
    }

    gen.writeEndObject();

    // Get the JSON string.
    return gen.getAsString();
  }
}