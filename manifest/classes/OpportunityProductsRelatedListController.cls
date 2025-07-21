public with sharing class OpportunityProductsRelatedListController {
  // Wrapper class to use on the VF page.
  public class Row {
    public OpportunityLineItem record { get; set; }
    public Integer indexInList { get; set; }

    public Row(OpportunityLineItem oli, Integer index) {
      record = oli;
      indexInList = index;
    }
  }

  public List<Row> oLineItemRows { get; set; }
  public Opportunity currentOpportunity { get; set; }

  // Property for Sorting
  public String orderBy { get; set; }
  public String sortOrder { get; set; }
  public String previousOrderBy { get; set; }

  // Property for Paging
  public Integer currentPage { get; set; }
  public Integer itemsPerPage { get; set; }
  public Integer totalPages { get; set; }
  public Integer totalRecordsFound { get; set; }

  public OpportunityProductsRelatedListController(
    ApexPages.standardController controller
  ) {
    try {
      // Set default values
      orderBy = 'Name';
      previousOrderBy = 'Name';
      sortOrder = 'ASC';
      itemsPerPage = 5;
      currentPage = 1;
      totalRecordsFound = 0;
      totalPages = 0;

      // Get current Opportunity
      currentOpportunity = [
        SELECT Id
        FROM Opportunity
        WHERE Id = :controller.getId()
      ];

      // Get the related Opportunity Line Items
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
      oLineItemRows = new List<Row>();

      // Get Opportunity Line Item fields to be queried from Field Set
      Id oppId = currentOpportunity.Id; // Filter Parent Id.
      String query = 'SELECT Id ';
      for (
        Schema.FieldSetMember f : Schema.SObjectType.OpportunityLineItem.fieldSets.getMap()
          .get('Fields_for_RelatedList')
          .getFields()
      ) {
        query += ',' + f.getFieldPath();
      }
      query +=
        ' FROM OpportunityLineItem WHERE OpportunityId =: oppId ORDER BY ' +
        orderBy +
        ' ' +
        sortOrder;

      if (sortOrder == 'ASC') {
        query += ' NULLS FIRST';
      } else {
        query += ' NULLS LAST';
      }

      // Query all child Opportunity line records from the current Opportunity
      List<OpportunityLineItem> allRecords = new List<OpportunityLineItem>();
      for (OpportunityLineItem acc : Database.query(query)) {
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
          oLineItemRows.add(r);
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