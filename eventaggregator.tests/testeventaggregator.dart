#import("../eventaggregator/eventaggregator.dart");

class Events{
 static final String PRINT_TITLE = "PRINT_TITLE";
 static final String INIT_TITLE = "INIT_TITLE";
}

class Page { String title; Page(this.title); }

void main() {
  var agg = GlobalEventManager.eventAggregator;
  var me = "The Caller";
  agg.sub(Events.PRINT_TITLE, me, (e) => print( "Loading: ".concat((e as EventArgs<Page>).payload.title)));
  agg.sub(Events.PRINT_TITLE, me, (e) => print( "Loaded: ".concat((e as EventArgs<Page>).payload.title)));
  agg.sub(Events.INIT_TITLE, me, (e) => print("Initing".concat((e as EventArgs<Page>).payload.title)));
  
  agg.pub(Events.PRINT_TITLE, new EventArgs<Page>(new Page("Page 1")));
  agg.pub(Events.INIT_TITLE, new EventArgs<Page>(new Page("Page 1")));
  agg.pub(Events.PRINT_TITLE, new EventArgs<Page>(new Page("Page 2")));
  agg.pub(Events.INIT_TITLE, new EventArgs<Page>(new Page("Page 2")));
  agg.pub(Events.PRINT_TITLE, new EventArgs<Page>(new Page("Page 3")));
  agg.pub(Events.INIT_TITLE, new EventArgs<Page>(new Page("Page 3")));
  agg.pub(Events.PRINT_TITLE, new EventArgs<Page>(new Page("Page 4")));
  agg.pub(Events.INIT_TITLE, new EventArgs<Page>(new Page("Page 4")));
  
  agg.unSub(Events.INIT_TITLE, me);
  print("After this point There would be no initialization.");
  agg.pub(Events.PRINT_TITLE, new EventArgs<Page>(new Page("Page 5")));
  agg.pub(Events.INIT_TITLE, new EventArgs<Page>(new Page("Page 5")));
  
  print("After this point nothing would happen.");
  agg.unSub(Events.PRINT_TITLE, me);
  agg.pub(Events.PRINT_TITLE, new EventArgs<Page>(new Page("Page 6")));
  agg.pub(Events.INIT_TITLE, new EventArgs<Page>(new Page("Page 6")));
}