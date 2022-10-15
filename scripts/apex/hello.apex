List<Order> orders = new List<Order>();

for (Integer i = 0; i < 5; i++) {
  Order o = new Order();
  o.AccountId = '0011X000014rCLJQA2';
  o.Status = 'Draft';
  o.EffectiveDate = Date.today();
  orders.add(o);
}

insert orders;

List<Order> orders = [SELECT Id FROM Order];
delete orders;
