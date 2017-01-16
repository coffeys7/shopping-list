# Simple List  
  
## Updating list items:  
```swift
// updating a list item
listEntity["label"] = newLabel
listEntity["subLabel"] = newSubLabel
listEntity["annotation"] = newAnnotation
listEntity["done"] = done

// update the change in the database
SCGraph.update()

// update/animate the change in the table view
self.animateUpdates()
```
