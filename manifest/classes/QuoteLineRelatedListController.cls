public with sharing class QuoteLineRelatedListController {
  // Wrapper class to use on the VF page.
  public class Row {
    public SBQQ__QuoteLine__c record { get; set; }
    public Integer indexInList { get; set; }

    public Row(SBQQ__QuoteLine__c qli, Integer index) {
      record = qli;
      indexInList = index;
    }
  }

  public List<Row> qLineItemRows { get; set; }
  public SBQQ__Quote__c currentQuote { get; set; }

  // Property for Sorting
  public String orderBy { get; set; }
  public String sortOrder { get; set; }
  public String previousOrderBy { get; set; }

  // Property for Paging
  public Integer currentPage { get; set; }
  public Integer itemsPerPage { get; set; }
  public Integer totalPages { get; set; }
  public Integer totalRecordsFound { get; set; }

  public QuoteLineRelatedListController(
    ApexPages.standardController controller
  ) {
    try {
      // Set default values
      //orderBy = 'Name';
      orderBy = 'SBQQ__Product__r.SBQQ__SortOrder__c';
      previousOrderBy = 'Name';
      sortOrder = 'ASC';
      itemsPerPage = 5;
      currentPage = 1;
      totalRecordsFound = 0;
      totalPages = 0;

      // Get current Quote
      currentQuote = [
        SELECT Id
        FROM SBQQ__Quote__c
        WHERE Id = :controller.getId()
      ];

      // Get the related Quote Line Items
      populateRows();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  // Method to do the query and populate current page rows
  public void populateRows() {
    try {
      qLineItemRows = new List<Row>();

      // Get SBQQ__QuoteLine__c fields to be queried from Field Set
      Id quoteId = currentQuote.Id; // Filter Parent Id.
      String query = 'SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.SBQQ__SortOrder__c ';
      for (
        Schema.FieldSetMember f : Schema.SObjectType.SBQQ__QuoteLine__c.fieldSets.getMap()
          .get('QuoteLine_Fields_for_RelatedList')
          .getFields()
      ) {
        query += ',' + f.getFieldPath();
      }
      query +=
        ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId ORDER BY ' +
        orderBy +
        ' ' +
        sortOrder;

      if (sortOrder == 'ASC') {
        query += ' NULLS FIRST';
      } else {
        query += ' NULLS LAST';
      }

      // Query all child quote line records from the current quote
      List<SBQQ__QuoteLine__c> allRecords = new List<SBQQ__QuoteLine__c>();
      for (SBQQ__QuoteLine__c acc : Database.query(query)) {
        allRecords.add(acc);
      }
      totalRecordsFound = allRecords.size();

      // Populate the current page to be shown to the user (according to the current pagination selection)
      if (allRecords.size() > 0) {
        totalPages =
          Decimal.valueOf(allRecords.size() / itemsPerPage).intValue() +
          (Math.mod(allRecords.size(), itemsPerPage) == 0 ? 0 : 1);

        if (currentPage > totalPages) {
          currentPage = totalPages;
        } else if (currentPage <= 0) {
          currentPage = 1;
        }

        Integer startIndex = (currentPage - 1) * itemsPerPage;
        Integer endIndex = allRecords.size() > (startIndex + itemsPerPage)
          ? (startIndex + itemsPerPage)
          : allRecords.size();

        Integer indexInPage = 0;
        for (Integer i = startIndex; i < endIndex; i++) {
          Row r = new Row(allRecords[i], indexInPage);
          qLineItemRows.add(r);
          indexInPage++;
        }
      } else {
        currentPage = 1;
        totalPages = 1;
      }

      allRecords = null;
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  // Method used to control the column sorting and re-generate the page after it
  public void doSortRows() {
    try {
      if (previousOrderBy.equals(orderBy)) {
        if (sortOrder.equals('ASC')) {
          sortOrder = 'DESC';
        } else {
          sortOrder = 'ASC';
        }
      } else {
        sortOrder = 'ASC';
        previousOrderBy = orderBy;
      }

      populateRows();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  // <!--  Pagination Section
  public void nextPage() {
    if (currentPage + 1 <= totalPages) {
      currentPage++;
      populateRows();
    }
  }

  public void prevPage() {
    if (currentPage - 1 >= 1) {
      currentPage--;
      populateRows();
    }
  }

  public void goToFirst() {
    currentPage = 1;
    populateRows();
  }

  public void goToLast() {
    currentPage = totalPages;
    populateRows();
  }
  // END Pagination controlling --!>
}