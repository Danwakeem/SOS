#Hey there,

This is an iPhone app that allows a user to save a location they might want to remember later. Imagine your self in a big parking lot and you don't remember where you parked. Well would't it be kind of cool if you could just flick down your notification center and click a button that says find my car and the app you opened has a map that tells you where to go to find your car? Well I thought it would be cool so I decided to start building this bad boy.

It should be easy to build but we will see. This it toally a work in progress so if you want to fork this project be prepaired it will be super ugly until I get all of the parts I want working working.

## My Core Data Model

So when I started designing my core data model I decided in the future I want to allow users to add as many items to their map as they want. I really want to keep the interface nice and simple so I am going to use the poo button as a toggle between all of the locations they have saved. So with that being said I just call the object being stored an object and the location saved as longitude and latitude.

Attrubute | Value
--------- | ------
object    | String
longitude | float
latitude  | float

## Featured to be added.

- [ ] Navigation
  - Drawing a route from where you are to the object you are looking for.

- [x] Today Widget
  - Today widget backend is basically done. I just need to replace the remove button with a navigation button so if you have your car location set it will open the container app and take you there.

- [x] Icon
  - This may change but for now it is just a little pin.

- [ ] Customer heading view
  - Have not given much thought to how I want the annotation heading to look but These shouldn't be to difficult to design so I will probably save it for last.

I am hoping to finish this bad boy and upload it to the app store over christmas berak :) 
