Data files and descriptions have been uploaded to the "energy" and "cuisine" folders, respectively

1) Appliance Energy Use

Predicting appliance energy use is an interesting problem because electrical energy cannot be created by power companies instantaneously. The companies need to have the foresight to have enough energy generated to meet peak demand while at the same time not over producing electricity that will not be used.

URL=https://www.sciencedirect.com/science/article/pii/S0378778816308970?via%3Dihub
DATA=http://archive.ics.uci.edu/ml/datasets/Appliances+energy+prediction

The dataset is time-dependent as well. The R script used for the academic paper uses the CARET (Classification and Regression Training) package to build a GBM model to predict appliance energy use.

------------------------------------------------------------------------------------------------------------------------------------------

2) Equities Momentum Strategy 

Removed because time-dependant data

------------------------------------------------------------------------------------------------------------------------------------------

3) Cuisine

Predicting the type of cuisine from a list of ingredients is an interesting problem because recipe websites would be able to automatically categorize the cuisine of a submitted recipe. The prediction could also be used to suggest recipes to user, so that these users can most effectively use the ingredients that they already have.

URL=https://www.kaggle.com/c/whats-cooking
DATA=https://www.kaggle.com/c/whats-cooking/data

The submitted R scripts found on Kaggle use the TM (Text Mining) R package to a collection of words in order to predict the cuisine.
