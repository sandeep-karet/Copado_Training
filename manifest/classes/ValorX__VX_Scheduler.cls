/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class VX_Scheduler {
    @WebService
    webService String AppId;
    @WebService
    webService String RefreshToken;
    @WebService
    webService List<ValorX.VX_Scheduler.VX_SchedulerDetail> SchedulerDetails;
    global VX_Scheduler() {

    }
global class VX_SchedulerDetail {
    @WebService
    webService Integer DayOfMonth;
    @WebService
    webService Date EndDate;
    @WebService
    webService Time EndTime;
    @WebService
    webService Boolean HasEndOfSchedule;
    @WebService
    webService Boolean IsDayOfMonth;
    @WebService
    webService Boolean IsEndAfter;
    @WebService
    webService Boolean IsEndOn;
    @WebService
    webService Boolean IsMonthlyFixed;
    @WebService
    webService Boolean IsMonthOfYear;
    @WebService
    webService Boolean IsYearlyMonthFixed;
    @WebService
    webService Integer MaxNoOfExecutions;
    @WebService
    webService Integer MonthOfYear;
    @WebService
    webService Integer RepeatMode;
    @WebService
    webService Date StartDate;
    @WebService
    webService Time StartTime;
    @WebService
    webService List<Integer> WeekDays;
    @WebService
    webService Integer WeekIntervalOfMonth;
    @WebService
    webService String WorkflowId;
    global VX_SchedulerDetail() {

    }
    global String GenerateCron() {
        return null;
    }
}
}
