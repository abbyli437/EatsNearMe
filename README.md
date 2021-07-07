# Original App Design Project - Eats Near Me

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
This app would be like Tinder but for restaurants. A user can filter for restaurants within a certain distance from their location (ie: 1.5 miles) and then swipe right/left to indicate if they would want to eat there or not, respectively. The restaurants that appear on the swipe feed would have a picture of food it serves plus some basic information like distance from user, price, and maybe a link to the website/menu. Restaurants that have been swiped right would be put on a bucket list for a user where they can view the restaurants on a map and check off items on the bucket list.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Lifestyle
- **Mobile:** This app requires the use of the user's location and probably a map to view restaurants with respect to the user.
- **Story:** I think the value of this app would be something that helps users decide where to eat next with very low effort on the users' part, as well as something that helps introduce them to local restaurants. I think my friends would like this because a lot of them moved to new cities for college and would probably appreciate something that helps them find new restaurants to try.
- **Market:** The marketplace is pretty large! I think anyone who is in a new place such as if they're on vacation or if they moved to a new city would benefit from this, as well as people who habitually struggle to decide what to eat.
- **Habit:** I think the app could actually be somewhat addictive if I can get a sophisticated enough algorithm. I find myself scrolling through Insta a lot looking at food so I feel like users could probably end up doing the same thing with my app. A user would not just consume my app because they can save restaurants and slowly check off their bucket list, which I think wouldbe satisfying.
- **Scope:** I think the scope would be reasonable. I think the basic features of the app would be feasible in the time I have and the stripped down version would still be interesting. I have a pretty clear idea of the product I want to build.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* users can create an account
* users can log in and out of their account
* users can search for restaurants within a certain distance from their location (maybe using the Google Maps SDK)
* users can swipe left or right on restaurants 
* users can save and view restaurants they swipe right on in a separate bucket list 
* users can get notified when they've swiped through all the restaurants near them

**Optional Nice-to-have Stories**

* users can check restaurants off on their bucket list 
* users can view their profile along with a few stats (number of restaurants visited, percentage of swipe rights)
* users can visit restaurants' websites or view their menus 
* users can pull up a map view of restaurants on their bucket list 
* users can get directions to restaurants in their bucket list 
* users' swipes can help decide which restaurant they see next on their feed using an algorithm on the backend 
* users can see popular restaurants near them- restaurants a certain percentage (ie: >= 70%) of users have seen and swiped right on 

### 2. Screen Archetypes

* Login screen
   * user can log in
   * user can also be redirected to create an account
* Registration screen
   * user can register for a new account
* Home feed screen
    * users can swipe left/right on restaurants (this should be animated)
    * users see a pop-up telling them they've swiped through all the restaurants in a certain distance from them
* Saved restaurants screen
    * users can view a list of restaurants they swiped right on 
* Settings screen
    * users can set their distance preferences (ie: restaurants 1.5 miles away)
    * users can log out 

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home feed
* Saved restaurants (list view)

**Flow Navigation** (Screen to Screen)

* Login screen
   * => home feed screen
   * => registration screen
* Registration screen
   * => home screen
* Home screen
    * => settings screen
* Saved restaurants screen
    * => settings screen

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="YOUR_WIREFRAME_IMAGE_URL" width=600>
<a href="/Users/abbyli/Downloads/fbu\ wireframe.JPG" target="_blank"><img src='/Users/abbyli/Downloads/fbu\ wireframe.JPG' title='' width='' alt='' /></a>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
