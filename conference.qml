import QtQuick
import org.qfield

Item {
  signal prepareResult(var details)
  signal fetchResultsEnded()
  
  function fetchResults(string, context, parameters) {
    let details = {
      "userData": {"type": "faux_gnss"},
      "displayString": "Switch to fake GNSS receiver",
      "actions":[]
    }
    prepareResult(details);
    details = {
      "userData": {"type": "splash"},
      "displayString": "Show splash screen",
      "actions":[]
    }
    prepareResult(details);
    
    fetchResultsEnded();
  }
}
