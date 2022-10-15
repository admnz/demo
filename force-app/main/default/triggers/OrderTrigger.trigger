trigger OrderTrigger on Order(after insert) {
  new OrderTriggerHandler().run();
}
