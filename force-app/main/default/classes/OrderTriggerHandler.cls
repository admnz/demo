public class OrderTriggerHandler extends TriggerHandler {
  public override void afterInsert() {
    List<Id> ids = new List<Id>(
      new Map<Id, Order>((List<Order>) Trigger.new).keySet()
    );
    OrderController.getExchangeRates(ids);
  }
}
