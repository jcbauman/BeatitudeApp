# “Beatitude”
An app to link Spotify playback with MapKit and allow users to create and experience location-based playlists.
​
## Audience
The app will target people with premium Spotify accounts, which includes 70 million people globally.  The app will interest people with a new take on music experience, and allow them to create and share mood and experiences 
​
## Experience
The app has a quick onboarding message of how it works then asks them to sign into Spotify one time.  The user will see a table-view of their created playlists with the option to create a new experience.  When the user creates a new experience, they are taken to a MapView where they are able to drop, edit, and delete pins and their corresponding radiuses to create zones.  As they set the zones, they are able to do a Spotify search for a song and set the link with Spotify URI.  In the experience list, users are able to play a playlist, which will run in the background updating users’ current location. As they enter a new tagged zone, the corresponding song will start playing in a Spotify player.
​
# Technical
## Models
We will be dealing with CoreData and MapKit Data
​
## Views
A Welcome View and Spotify login page
A table view of playlists with an add and edit button, displaying playlist names and mini descriptions.
A Map with Spotify search bar for creating experiences.
​
## Controllers
I will need a view controller for each screen.
​
## Other
I will need to integrate Spotify SDK and Mapkit.  I was hoping to have a sharing aspect of the playlists, like a linking, so maybe Firebase.
​
# Weekly Milestone
## Week 4 - Usable Build
- Create a Mapview
- Integrate Spotify and search and linking
​
## Week 5 - Finish Features
- Core Data to store playlist info
- Player
​
## Week 6 - Polish
- Beautification
- Sharing Element (if possible)

