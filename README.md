## Add Zendesk doc labels

This application allows you to change the labels for documentation stored in Zendesk's Help Desk.  Labels can be used by other tools (like AnswerBot) to automatically provide doc answers to your clients.

## Summary

A ruby application accepts your Zendesk credentials then prompts you for something to do (very 1995...)  The application allows you to list categories and sections in categories.  The application allows you to add labels to articles.

## Prerequisites

* [Ruby](https://www.ruby-lang.org/en/downloads/) version 2.3.5 or better.  If you have a Mac, this may already be installed.  Just sayin'...
* Zendesk credentials that allow the user to edit articles
* List of articles and the label(s) that you want to go on them

## Setup

You must provide a YAML file containing the zendesk hostname and your credentials. Here's a sample for a company whose Zendesk URL starts with `https://bongosupport.zendesk.com`. 

```yaml
DOMAIN: bongosupport
EMAIL: bon@go.bizi
PASSWORD: aliens! there are aliens!
```
You can find a template for this YAML file in `args.yaml`.  For the purposes of this article, these settings will appear in a file called `bongo.yaml`.

## Running the app

## See the help.
```bash
ruby bulk_add_labels.rb --help
```
Displays
```bash
Usage: bulk_add_label.rb [options]
    -c, --config=FILE                YAML configuration file
    -h, --help                       Prints this help
```
## Start the app
```bash
ruby bulk_add_labels.rb --config bongo.yaml
```
Displays the main menu.
```bash
Please choose one of the following options
1. List Categories
2. List Sections in a Category
3. List Articles in a Section
4. Choose Category and add answer-bot label to the articles in that category (long)
5. Choose Section and add answer-bot label to the articles in that section
6. Dump (long)
7. Exit

```
Type the number for the action of your choice.  Tap enter.  The next section details each command.

## Command details

### 1. List Categories

Shows all of the categories that are visible to the credentials in the YAML file.  Here's a sample.
```bash
1 [Enter]
203291467 -> Salsa Engage Help Documentation
203862367 -> Salsa CRM Help Documentation
203291447 -> Salsa Classic Help Documentation
203862748 -> Salsa Donate Help Documentation
203291427 -> DonorPro Help Documentation
```

### 2. List Sections in a category

Accepts a category ID and displays the sections.  Note that the ID is the long bunch of numbers before the description.  That's important.

Here's a sample that shows the sections for "Salsa Classic Help Documention"
```
2 [Enter]
Alrighty, give me the category_id
203291447 [Enter]
203291447: Salsa Classic Help Documentation
* 360000384954 -> Announcements
* 205164287 -> New Users
* 205164307 -> Advocacy
* 205164207 -> Chapters & Syndication
* 205164327 -> Donations
* 205164167 -> Email Blasts
* 205164367 -> Events
. . .
```
### 3. List Articles in a Section

Accepts a section ID and displays lists the articles.  The labels for each article appear after the title.

Here's a sample:
```
3 [Enter]
Alright, give me the section_id
205164307 [Enter]
115000177854	'Loading Targets ...' error	[classic, classic_advocacy]
115000113893	Target filtering in Advocacy 4	[classic, classic_advocacy]
115000092013	Action error: Sorry, we couldn't find your address	[classic, classic_advocacy]
223343627	Petition	[classic, classic_advocacy]
223343607	Targeted / Blind Targeted Action	[classic, classic_advocacy]
223343587	Multi-content Targeted Action	[classic, classic_advocacy]

. . .
```

### 4. Choose Category and add answer-bot label to the articles in that category (long)

Choosing "4" allows you to add a label to _all_ articles in _all_ sections in a category.  

The user types/pastes in a category ID (the long stream of numbers before the category name).  The application provides a feed back in the form of the category name for the selected ID

After accepting the label(s), the app iterates through all sections and adds the label to all articles in each section.

The usual "you should be careful" warning applies.

Here's a sample.
```bash
4 [Enter]
Alrighty, give me the category_id
203291447 [Enter]
203291447: Salsa Classic Help Documentation
Alright, add which label(s)? example: answer-bot or answer-bot,cow,moose
classic [Enter]
* 360004772754: What is GDPR?
* 360001713174: TLS 1.0 Sunset Overview and Schedule - Everything You Need to Know
* 360001706873: TLS 1.0 Sunset Overview and Schedule - Everything You Need to Know
. . .
```
This takes a _very_ long time to run.  See the "Notes" section if you're curious why.

### 5. Choose Section and add answer-bot label to the articles in that section

Choosing "5" allows you to add a label to all articles in a section.  The user supplies a section ID (the long string of numbers before the section name.)  The application provides a feed back in the form of the section name for the selected id.

After accepting the label(s), the app iterates through all sections and adds the label to all articles in each section.

Here's a sample.
```bash
5 [Enter]
Alright, give me the section_id
205164307 [Enter]
205164307: Advocacy
Alright, add which label(s)? example: answer-bot or answer-bot,cow,moose
classic_advocacy
* 115000177854: 'Loading Targets ...' error
* 115000113893: Target filtering in Advocacy 4
* 115000092013: Action error: Sorry, we could not find your address
* 223343627: Petition
* 223343607: Targeted / Blind Targeted Action
. . .
```

### 6. Dump (long)

This command displays an indented list of categories, sections and articles.  It can go on for a while...

Here's a sample.
```bash
6 [Enter]

203291467 -> Salsa Engage Help Documentation has 9 sections

    360000307913 -> Engage Announcements has 9 articles
        360001924894 -> Events and Peer-to-Peer Improvements - March 2018 [engage]
        360003572574 -> New and Improved! [engage]
        360001402193 -> TLS 1.0 Sunset Overview and Schedule - Everything You Need to Know [engage]
        360004808813 -> What is GDPR? [engage]
        360001712354 -> What Salsa Product Am I Using? [engage]
        . . .

    205405287 -> Getting Started and Settings has 9 articles
        224402148 -> Account Setup [engage]
        229498947 -> Dashboard Snapshot [engage]
        224340067 -> Settings: Introduction [engage]
        115000510013 -> Done - S31 - Draft complete - Authenticate Emails [engage]
        115000319853 -> Done - S31 - Draft complete - Social Media Accounts: Add Social Accounts [engage]
        360003190093 -> Email & Form Defaults [engage]
    . . .
```

### 7. Exit

Choosing "7" stops the application.  If you are stopping for the last time then _be very sure_ to remove the YAML configuration file!  It contains your Zendesk credentials and you _do not_ want that file to be stolen.

## Questions?  Comments?

Use the `Issues` link at the top of GitHub repository.

## Kudos.

My heartfelt thanks and appreciation to the folks at [Zendesk](https://www.zendesk.com) for creating such a great product *and* documenting it so clearly.
