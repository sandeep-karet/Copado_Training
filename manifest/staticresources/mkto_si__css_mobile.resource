/*Mobile
*/

body {
    padding: 0 !important;
    background-image: none !important;
    min-width: unset;
}

body .bPageBlock.secondaryPalette {
    background-color: #f3f2f2;
    border: none;
}

.pbBody {
    margin: 0 !important;
}

.db-mobile-content {
    font-family: Graphik;
    color: #333;
    font-size: 12px;
}

.unselectable {
  user-select: none;
  -moz-user-select: none;
  -webkit-user-select: none;
  -ms-user-select: none;
}

.db-mobile-content .mobile-data-list {
    padding: 0;
    margin: 0;
}

.db-mobile-content .mobile-data-list > li {
    display: block;
    background-color: rgb(255, 255, 255);
    margin: 14px;
    padding: 14px 10px;
    border: 1px solid rgb(223, 224, 225);
    border-radius: 3px;
}

.db-mobile-content select#mktActions {
    width: 5px;
    background: none;
    border: none;
    position: relative;
    left: 65px;
    min-width: 0;
    padding: 8px;
}

.db-mobile-content .three-dots {
    font-size: 26px;
    color: #006eb3;
    vertical-align: sub;
}

.db-mobile-content select.db-views-list {
    width: 170px;
    -webkit-appearance: none;
    padding: 8px;
    background: url(https://s3.amazonaws.com/marketo-sales-insight/images/chevron-up_down.svg) right no-repeat;
    background-size: 19px;
    font-size: 12px;
}

.marketoActionLinks {
    visibility: hidden;
    width: 1px;
    height: 1px;
}

.db-mobile-content .flex-box {
    display: flex;
    justify-content: space-between;
}

.db-mobile-content .separator {
    border-bottom: 1px solid rgb(223, 224, 225);
    margin: 12px 0 10px;
}

.db-mobile-content .grouped-header {
    margin: 14px;
}

.db-mobile-content .bookmark-active-true > svg {
  fill: #3882d3;
}

.db-mobile-content .account-name {
    color: #666;
    word-break: break-word;
}

.db-mobile-content .contact-name {
    font-weight: 500;
    font-size: 14px;
    word-break: break-word;
}

.db-mobile-content .account-name-link,
.db-mobile-content .contact-name-link {
  color: #000;
}

.db-mobile-content .item-header {
    margin-bottom: 3px;
}

.db-mobile-content .item-big-header {
    margin-bottom: 14px;
}

.db-mobile-content .sub-header {
    font-size: 10px;
    color: #666;
    margin-bottom: 3px;
    word-break: break-word;
}

.db-mobile-content .item-data {
    margin: 0 4px;
}

.db-mobile-content .last-item, .db-mobile-content .first-item {
    margin-top: 10px;
}

.db-mobile-content .large-text {
    font-size: 18px;
    word-break: break-word;
}

.db-mobile-content .middle-text {
    font-size: 14px;
    word-break: break-word;
}

.db-mobile-content .small-text {
    font-size: 12px;
}

.db-mobile-content .right-align {
    text-align: right;
}

.db-mobile-content .mobile-tab-header {
    background-color: rgb(255, 255, 255);
    padding: 14px;
}

.mobile-tab-header .pageTitleIcon {
    background-image: none;
}

.mobile-tab-header .bPageTitle .ptBody .content {
    padding: 0;
    width: auto;
}

.mobile-tab-header .bPageTitle:last-child {
    margin: 0;
}

.db-mobile-content .bPageTitle {
    padding: 0;
}

/* Send Email Page*/

.mobile-tab-header .bPageTitle .ptBody h1.noSecondHeader {
    font: 500 1.5em 'Graphik' !important;
}

.db-mobile-content .label-data-box {
    display: flex;
    margin: 14px;
}

.db-mobile-content .label-data-box > :first-child {
    width: 16%;
    padding-right: 14px;
    text-align: right;
}

.db-mobile-content .with-field-label > :first-child {
    padding-top: 10px;
}

.db-mobile-content .x-html-editor-tb {
    display: none;
}

.db-mobile-content .form-control {
    width: 180px;
    padding: 8px;
    background: none;
    background-color: white;
    font-size: 12px;
    border: 1px solid rgb(169, 169, 169);
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
    border-radius: 5px;
}

.db-mobile-content .email-template {
    border-right: none;
    border-radius: 5px 0 0 5px;
}

.db-mobile-content .template-desc {
    width: 270px;
    margin-top: 8px;
}

.db-mobile-content .x-html-editor-wrap {
    border-radius: 5px;
    -moz-border-radius: 5px;
    -webkit-border-radius: 5px;
    overflow: scroll;
    padding: 2px;
}

/*  Send Email Buttons  */

.db-mobile-content .action-buttons {
    margin: 20px;
}

.db-mobile-content .action-buttons .btn {
    padding: 8px;
    color: white;
    background: inherit;
}

.db-mobile-content .action-buttons .marketo-email-button {
    border: 1px solid rgb(0, 112, 210);
    background-image: linear-gradient(rgb(0, 112, 210), rgb(0, 112, 210));
}

.db-mobile-content .action-buttons .test-email-button {
    border: 1px solid rgb(169, 169, 169);
    color: rgb(169, 169, 169);
    margin-right: 20px;
}

.db-mobile-content .action-buttons .test-email-warning {
    display: inline-block;
    margin-right: 16px;
}

.db-mobile-content .action-buttons .cancel-button {
    color: rgb(0, 112, 210);
    border: none;
}

/* Add To Campaign Buttons */

.db-mobile-content .add-to-campaign-buttons {
    text-align: right;
    margin-top: 10px;
}

.db-mobile-content .add-to-campaign-buttons  input {
    color: white;
    padding: 8px;
    background-color: rgb(0, 112, 210);
    border-color: rgb(0, 112, 210);
    background-image: none;
}

/*  Add To Campaign Page  */

.db-mobile-content select.db-campaigns-list {
    width: 100%;
}

.db-mobile-content .message {
    margin: 4px 20px;
}

.db-mobile-content .x-form-arrow-trigger {
    background: url(https://s3.amazonaws.com/marketo-sales-insight/images/chevron-up_down.svg) right no-repeat;
    background-size: 19px;
    background-color: white;
    border: 1px solid rgb(169, 169, 169);
    border-left: none;
    height: 34px;
    border-radius: 0 5px 5px 0;
}

.db-mobile-content .total-score {
    font-size: 22px;
    font-weight: bold;
}

.db-mobile-content .mktPosScoreChange {
    color: green;
}

.db-mobile-content .mktNoScoreChange {
    display: none;
}

.db-mobile-content .mktNegScoreChange {
    color: red;
}

.db-mobile-content .mkt-tabs-message {
    margin-top: 14px;
}

.mkt-mobile {
    padding: 50px;
    color: red;
}

.mkt-mobile-hide-m {
    /* Hide for mobile */
    display: none !important;
}

.mkt-mobile-hide-d {
    /* Hide for desktop, but show on mobile */
    display: inline;
}

.mkt-link  a,.mkt-link a:hover,.mkt-link a:visited {
    text-decoration: none;
    font-size: 18px;
    font-weight: bold;
}

a:hover span{
    text-decoration: none;
}

.mkt-text-decoration {
    text-decoration: none;
}

.mkt-mobile-time {
    color: #A1A6A9;
    float: right;
    padding-top: 5px;
}

.noselect {
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    -khtml-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
}

.mkt-mobile-leadfeed-name {
    padding-left:30px;
}

.db-mobile-content .subscribe-icon {
    word-break: unset;
}

.mkt-amc-header {
    background: white;
}

.mkt-header-button {
    color: #7e7f80 !important;
}

.mkt-header-button a:visited {
  color: #7e7f80 !important;;
}

.mkt-header-button a:link {
  color: #7e7f80 !important;
}

.mkt-amc-title {
    border-bottom: 3px solid #d6dee4;
    border-top: 3px solid #d6dee4;
    padding: 8px 14px;
}

#mkt-mobile-loading {
    position: absolute !important;
    width: 100%;
    height: 100%;
    display:none;
    background-color: #F0F1F2;
    /*z-index: 999;*/
}

#mktSubmitDelegate {
    -webkit-appearance: none;
    -webkit-background-clip: border-box;
    -webkit-background-origin: padding-box;
    -webkit-background-size: auto;
    -webkit-box-shadow: none;
    -webkit-font-smoothing: antialiased;
    background-image: none;
    border-color: rgba(0, 0, 0, 0);
}

/* Send Marketo Email select template tree */

.mktEmailTreePanel .x-tree-node-el {
    font-size: 16px;
    line-height: 32px;
}

.mktEmailTreePanel  .x-tree-node-icon {
    vertical-align: text-top;
    margin-right: 2px;
}

.mktEmailTreePanel .x-tree-ec-icon {
    margin-top: 6px;
}