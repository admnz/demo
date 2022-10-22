@isTest
private class OrderControllerTest {
  @isTest
  static void testGetExchangeRates() {
    ExchangeRateAPI__c api = new ExchangeRateAPI__c();
    api.Endpoint__c = 'https://exchangerate.api';
    insert api;

    Account account = new Account();
    account.Name = 'acc';
    insert account;

    List<Order> oList = new List<Order>();
    Order order = new Order();
    order.AccountId = account.Id;
    order.Status = 'Draft';
    order.EffectiveDate = Date.today();
    order.USD__c = null;
    order.CAD__c = null;
    order.Exchange_Rate_Last_Update__c = null;
    oList.add(order);
    insert oList;

    List<Id> idList = new List<Id>(
      new Map<Id, Order>((List<Order>) oList).keySet()
    );

    Test.startTest();
    Test.setMock(HttpcalloutMock.class, new MockHttpResponse());
    OrderController.getExchangeRates(idList);
    Test.stopTest();

    Order o = [SELECT Id, USD__c, CAD__c FROM Order][0];
    System.assert(
      o.USD__c != null &&
      o.CAD__c != null &&
      o.Exchange_Rate_Last_Update__c != null,
      'Exchange Rates shouldn\'t be NULL.'
    );
  }

  public class MockHttpResponse implements HttpCalloutMock {
    String json =
      '{' +
      '  "result": "success",' +
      '  "time_last_update_unix": 1666396801,' +
      '  "base_code": "EUR",' +
      '  "conversion_rates": {' +
      '    "CAD": 1.3445,' +
      '    "GBP": 0.8740,' +
      '    "USD": 0.9818' +
      '  }' +
      '}';

    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(json);
      res.setStatusCode(200);
      return res;
    }
  }
}
