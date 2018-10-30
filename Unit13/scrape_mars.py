from flask import Flask, render_template, redirect
from flask_pymongo import PyMongo
import scrape_craigslist

app = Flask(__name__)

# Use flask_pymongo to set up mongo connection
app.config["MONGO_URI"] = "mongodb://localhost:27017/craigslist_app"
mongo = PyMongo(app)

# Or set inline
# mongo = PyMongo(app, uri="mongodb://localhost:27017/craigslist_app")


@app.route("/")
def index():
    listings = mongo.db.listings.find_one()
    return render_template("index.html", listings=listings)


@app.route("/scrape")
def scraper():
	#create a listings collection
    listings = mongo.db.listings
    #call the scrape function in our scrap_craigslist file.  This will scrape and save to Mongo
    listings_data = scrape_craigslist.scrape()
    #update our listings with the data that is being scraped
    listings.update({}, listings_data, upsert=True)
    #return a message to our page so we know it was successful
    return redirect("/", code=302)


if __name__ == "__main__":
    app.run(debug=True)
