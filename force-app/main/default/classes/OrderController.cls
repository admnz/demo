public without sharing class OrderController {
  @future(callout=true)
  public static void getExchangeRates(List<Id> ids) {
    ExchangeRateAPI__c api = ExchangeRateAPI__c.getOrgDefaults();
    Date lastUpdate;
    Decimal usd;
    Decimal cad;

    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(api.Endpoint__c);
    request.setMethod('GET');
    request.setHeader('Content-Type', 'application/json');

    try {
      HttpResponse response = http.send(request);

      if (response.getStatusCode() == 200) {
        JSONParser parser = JSON.createParser(response.getBody());

        while (parser.nextToken() != null) {
          if (parser.getText() == 'time_last_update_unix') {
            parser.nextToken();
            lastUpdate = Datetime.newinstance(
                long.valueOf(parser.getText() + '000')
              )
              .date();
          }
          if (parser.getText() == 'USD') {
            parser.nextToken();
            usd = Decimal.valueOf(parser.getText());
          }
          if (parser.getText() == 'CAD') {
            parser.nextToken();
            cad = Decimal.valueOf(parser.getText());
          }
        }
      }
    } catch (System.CalloutException e) {
      System.debug('ERROR: ' + e.getMessage());
    }

    if (usd != null && cad != null) {
      List<Order> orders = [
        SELECT Id, USD__c, CAD__c
        FROM Order
        WHERE Id = :ids
      ];

      for (Order o : orders) {
        o.Exchange_Rate_Last_Update__c = lastUpdate;
        o.USD__c = usd;
        o.CAD__c = cad;
      }

      try {
        update orders;
      } catch (DmlException e) {
        System.debug(e.getMessage());
      }
    }
  }
}
