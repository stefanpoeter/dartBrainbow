
#import('dart:html');
#import('./lib/bb.dart');
num rotatePos = 0;

void main() {

  query('#calc').on.click.add(calculate);
}

void calculate(Event event) {
  event.preventDefault();
  try {
    InputElement ie = query('#seq');
    BBSeq seq = BBUtils.normalize(new BBSeq(ie.value));
    query('#text').text = seq.toString();
    query("#result").text = BBUtils.calc(seq).toString();
  } catch (Exception e) {
    
  }
  
}
