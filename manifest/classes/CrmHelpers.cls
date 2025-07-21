// CRM-wide functions
public class CrmHelpers {
    public static Date validBusinessDate(Date proposedDate){
        // Store org holidays in GMT format.
        Set<Date> nextFewHolidays = new Set<Date>();
        for(Holiday tmpHoliday : [Select h.StartTimeInMinutes, h.Name, h.ActivityDate 
                                  From Holiday h 
                                  where ActivityDate > TODAY order by ActivityDate limit 10])
        {
            // Store new instance to strip timezone offset.
            Date tmpDate = Date.newInstance(
                tmpHoliday.ActivityDate.year(),
                tmpHoliday.ActivityDate.month(),
                tmpHoliday.ActivityDate.day());
            nextFewHolidays.add(tmpDate);
        }
        System.Debug(LoggingLevel.FINER,'Dates loaded: ' + nextFewHolidays );
        // Name days of the week to skip
        Set<String> weekendOffsets = new Set<String>{'Sat','Sun'};
            // Use datetime so we can easily add days
            DateTime targetDate = DateTime.newInstance(
                proposedDate.year(),
                proposedDate.month(),
                proposedDate.day());
        
        // Prepare to loop through upcoming days.
        Boolean nextBusinessDay = false;
        Date nextValidDate = null;
        do {
            String dayOfWeek = targetDate.format('E'); // Yields 'Sun','Mon', etc.
            if(weekendOffsets.contains(dayOfWeek)){
                system.debug(LoggingLevel.FINER,'falls on weekend');
                targetDate = targetDate.addDays(1);
            } else {
                // If not a weekend then check if a holiday using date without timezone
                Date candiDate = Date.newInstance(
                    targetDate.year(),
                    targetDate.month(),
                    targetDate.day());
                
                if(nextFewHolidays.contains(candiDate)){
                    targetDate = targetDate.addDays(1);
                } else {
                    // If we have a valid date then break us out of the loop
                    system.debug(LoggingLevel.FINER,'valid date: ' + candiDate);
                    nextValidDate = candiDate;
                    nextBusinessDay = true;
                }
            }
        } while (!nextBusinessDay);
        // return next non-weekend, non-holiday date
        return nextValidDate;
    }
}