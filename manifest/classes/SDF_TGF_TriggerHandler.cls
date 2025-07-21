/**
 * @author Wenbo Zhou
 * @date 2021-05-16
 * @description An opinionated trigger handler framework.
 *
 * Originally from github.com/trailheadapps/apex-recipes
 */

//PMD.ExcessivePublicCount: a common framework class that needs public methods to set behaviour for trigger handlers.
//PMD.CyclomaticComplexity: a common framework class which has bootstrap codes for trigger handlers.
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CyclomaticComplexity')
public virtual class SDF_TGF_TriggerHandler {
    public static final String TRIGGER_NO_CONTEXT_ERR
        = 'Trigger handler called outside of Trigger execution';
    public static final String TRIGGER_INVALID_CTX_ERR
        = 'Unexpected trigger context set: ';

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;

    // the current context of the trigger, overridable in tests
    @TestVisible
    protected TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }

    /**
     * @description Internal TriggerHandler custom exception class
     */
    public class TriggerHandlerException extends Exception {
    }

    /**
     * @description Constructs a trigger handler object and ensures the context
     * is set
     */
    public SDF_TGF_TriggerHandler() {
        this.setTriggerContext();
    }

    /**
     * @description This is main brokering method that is called by the trigger.
     * It's responsible for determining the proper context, and calling the
     * correct method
     * @example
     * AccountTriggerHandler.run();
     */
    public virtual void run() {
        if (!validateRun()) {
            return;
        }

        addToLoopCount();
        dispatchHandler(this);
    }

    /**
     * @description execute the handler method with current context
     * @param currentHandler An instance of the SDF_TGF_TriggerHandler handler class
     */
    protected virtual void dispatchHandler(SDF_TGF_TriggerHandler currentHandler) {
        // dispatch to the correct handler method
        switch on context {
            when BEFORE_INSERT {
                currentHandler.beforeInsert();
            }
            when BEFORE_UPDATE {
                currentHandler.beforeUpdate();
            }
            when AFTER_INSERT {
                currentHandler.afterInsert();
            }
            when AFTER_UPDATE {
                currentHandler.afterUpdate();
            }
            when BEFORE_DELETE {
                currentHandler.beforeDelete();
            }
            when AFTER_DELETE {
                currentHandler.afterDelete();
            }
            when AFTER_UNDELETE {
                currentHandler.afterUndelete();
            }
        }
    }

    /**
     * @description Allows developers to prevent trigger loops, or allow
     * a limited number of them by setting the maximum number of times
     * the current trigger handler is called.
     * This method is used when a handler is directly inherited this virtual class.
     * @param max   A valid number (generally 1) of times you'd like
     * to allow the trigger to run.
     * @example
     * In the context of a TriggerHandler class,
     * this.setMaxLoopCount(5);
     */
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        this.setMaxLoopCount(handlerName, max);
    }

    /**
     * @description Allows developers to prevent trigger loops, or allow
     * a limited number of them by setting the maximum number of times
     * a named trigger is called.
     * @param handlerName A valid handler name
     * @param max   A valid number (generally 1) of times you'd like
     * to allow the trigger to run.
     * @example
     * In the context of a TriggerHandler class,
     * this.setMaxLoopCount('AccountHandler', 5);
     */
    public void setMaxLoopCount(String handlerName, Integer max) {
        if (!SDF_TGF_TriggerHandler.loopCountMap.containsKey(handlerName)) {
            SDF_TGF_TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            SDF_TGF_TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    /**
     * @description Allows developers to turn off the max loop count for the current trigger handler
     * This method is used when a handler is directly inherited this virtual class.
     * @example
     * In the context of a TriggerHandler class,
     * this.clearMaxLoopCount();
     */
    public void clearMaxLoopCount() {
        String handlerName = getHandlerName();
        this.clearMaxLoopCount(handlerName);
    }

    /**
     * @description Allows developers to turn off the max loop count
     * @param handlerName a name for the trigger handler
     * @example
     * In the context of a TriggerHandler class,
     * this.clearMaxLoopCount('AccountHandler');
     */
    public void clearMaxLoopCount(String handlerName) {
        this.setMaxLoopCount(handlerName, -1);
    }

    /**
     * @description       Allows developers to conditionally bypass (disable)
     * other triggers that *also* implement this triggerHandler
     * @param handlerName Class name (String) of the trigger handler to bypass
     * @example
     * TriggerHandler.bypass('AccountTriggerHandler');
     */
    public static void bypass(String handlerName) {
        SDF_TGF_TriggerHandler.bypassedHandlers.add(handlerName);
    }

    /**
     * @description       Removes a given trigger handler class name from
     * the list of bypassed trigger handlers.
     * @param handlerName Handler class name to remove from the bypass list
     * @example
     * TriggerHandler.clearBypass('AccountTriggerHandler');
     */
    public static void clearBypass(String handlerName) {
        SDF_TGF_TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    /**
     * @description       Allows developers to check whether a given trigger
     * handler class is currently bypassed.
     * @param handlerName The name of the trigger handler class to check for
     * @return           `Boolean`
     * @example
     * TriggerHandler.isBypassed('AccountTriggerHandler');
     */
    public static Boolean isBypassed(String handlerName) {
        return SDF_TGF_TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    /**
     * @description removes all classes from the bypass list
     * @example
     * Triggerhandler.clearAllBypasses();
     */
    public static void clearAllBypasses() {
        SDF_TGF_TriggerHandler.bypassedHandlers.clear();
    }

    /***************************************
     * private instancemethods
     ***************************************/

    /**
     * @description internal method to forcibly set the trigger context
     */
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    /**
     * @description    Internal method for manually setting the trigger context
     * @param ctx      The current trigger Context
     * @param testMode Is the trigger running in a test context?
     */
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if (Trigger.isExecuting && !testMode) {
            switch on Trigger.operationType {
                when BEFORE_INSERT {
                    context = TriggerContext.BEFORE_INSERT;
                }
                when BEFORE_UPDATE {
                    context = TriggerContext.BEFORE_UPDATE;
                }
                when BEFORE_DELETE {
                    context = TriggerContext.BEFORE_DELETE;
                }
                when AFTER_INSERT {
                    context = TriggerContext.AFTER_INSERT;
                }
                when AFTER_UPDATE {
                    context = TriggerContext.AFTER_UPDATE;
                }
                when AFTER_DELETE {
                    context = TriggerContext.AFTER_DELETE;
                }
                when AFTER_UNDELETE {
                    context = TriggerContext.AFTER_UNDELETE;
                }
            }
        } else if (ctx != null && testMode) {
            switch on ctx {
                when 'before insert' {
                    context = TriggerContext.BEFORE_INSERT;
                }
                when 'before update' {
                    context = TriggerContext.BEFORE_UPDATE;
                }
                when 'before delete' {
                    context = TriggerContext.BEFORE_DELETE;
                }
                when 'after insert' {
                    context = TriggerContext.AFTER_INSERT;
                }
                when 'after update' {
                    context = TriggerContext.AFTER_UPDATE;
                }
                when 'after delete' {
                    context = TriggerContext.AFTER_DELETE;
                }
                when 'after undelete' {
                    context = TriggerContext.AFTER_UNDELETE;
                }
                when else {
                    throw new SDF_TGF_TriggerHandler.TriggerHandlerException(
                        SDF_TGF_TriggerHandler.TRIGGER_INVALID_CTX_ERR + ctx
                    );
                }
            }
        }
    }

    /**
     * @description increment the loop count for the current trigger handler
     * This method is used when a handler is directly inherited this virtual class.
     */
    @TestVisible
    protected void addToLoopCount() {
        String handlerName = getHandlerName();
        this.addToLoopCount(handlerName);
    }

    /**
     * @description increment the loop count
     * @param handlerName a name for the trigger handler
     * @throws  TriggerHandlerException - a loop count exception if the max loop count is reached
     */
    @TestVisible
    protected void addToLoopCount(String handlerName) {
        if (SDF_TGF_TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = SDF_TGF_TriggerHandler.loopCountMap.get(handlerName)
                .increment();
            if (exceeded) {
                Integer max = SDF_TGF_TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException(
                    'Maximum loop count of ' +
                        String.valueOf(max) +
                        ' reached in ' +
                        handlerName
                );
            }
        }
    }

    /**
     * @description make sure this trigger should continue to run
     * This method is used when a handler is directly inherited this virtual class.
     * @return     `Boolean`
     * @throws   TriggerHandlerException thrown when executing outside of a
     * trigger
     */
    @TestVisible
    protected Boolean validateRun() {
        String handlerName = getHandlerName();
        return validateRun(handlerName);
    }

    /**
     * @description check whether a named trigger should continue to run
     * @param handlerName a name for the trigger handler
     * @return     `Boolean`
     * @throws   TriggerHandlerException thrown when executing outside of a
     * trigger
     */
    @TestVisible
    protected Boolean validateRun(String handlerName) {
        if (!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException(
                SDF_TGF_TriggerHandler.TRIGGER_NO_CONTEXT_ERR
            );
        }
        if (SDF_TGF_TriggerHandler.bypassedHandlers.contains(handlerName)) {
            return false;
        }
        return true;
    }

    /**
     * @description Returns the string version of the handler class being
     * invoked
     * @return     `String` Name of the Handler
     */
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this)
            .substring(0, String.valueOf(this).indexOf(':'));
    }

    /***************************************
     * context methods
     ***************************************/

    /**
     * These methods are all intended to be overridden by
     * individual trigger handlers. They exist here only to
     * establish the 'software contract' that they exist.
     */

    /**
     * @description Virtual method for the implementing class to override
     */
    @TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeInsert() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeUpdate() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeDelete() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterInsert() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterUpdate() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterDelete() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @TestVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterUndelete() {
    }

    /***************************************
     * inner classes
     ***************************************/

    /**
     * @description inner class for managing the loop count per handler
     */
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;

        /**
         * @description Loop counter method with default of 5.
         */
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        /**
         * @description Sets loop count based on the param.
         * @param max   Maximum number of loops to allow.
         */
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        /**
         * @description Increment the internal counter returning the results of
         * this.exceeded().
         * @return     `Boolean` true if count will exceed max count or is less
         * than 0.
         */
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        /**
         * @description Determines if this we're about to exceed the loop count.
         * @return     `Boolean` true if less than 0 or more than max.
         */
        public Boolean exceeded() {
            if (this.max < 0) {
                return false;
            }
            if (this.count > this.max) {
                return true;
            }
            return false;
        }

        /**
         * @description Returns the max loop count.
         * @return     `Integer` max loop count.
         */
        public Integer getMax() {
            return this.max;
        }

        /**
         * @description Returns the current loop count.
         * @return     `Integer` current loop count.
         */
        public Integer getCount() {
            return this.count;
        }

        /**
         * @description Sets the max loop size
         * @param max   The integer to set max to.
         */
        public void setMax(Integer max) {
            this.max = max;
        }
    }

    /**
     * @description possible trigger contexts
     */
    public enum TriggerContext {
        BEFORE_INSERT,
        BEFORE_UPDATE,
        BEFORE_DELETE,
        AFTER_INSERT,
        AFTER_UPDATE,
        AFTER_DELETE,
        AFTER_UNDELETE
    }
}