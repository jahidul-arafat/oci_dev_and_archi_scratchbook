# Binary classification of iris data
'''
- Note, we dont need to scale the target labels (y) because they are not used directly in the optimization process of most algorithm
- We will be only scaling the features (X_train)

Why Scaling the features?
- We want to make sure that the features are not influenced by the scale of the target labels
- To make sure that all the features have equal contribution to euclidean distance calculation, leading to a better comparison and classification

'''
import random

import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, log_loss
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import StratifiedKFold

# load the Iris dataset
iris = load_iris()
X = iris.data
y = iris.target
feature_names = iris.feature_names
class_names = iris.target_names

# print the feature names and class names
print(feature_names)
print(class_names)

# create a panda DataFrame with the data and target labels
df = pd.DataFrame(X, columns=feature_names)
# df['target'] = y


# map the target labels to class names
df['Target'] = [class_names[i] for i in y]  # Mapping target labels to class names

# Select 10 random rows with different target labels
random.seed(42)  # Set a random seed for reproducibility
random_indices = random.sample(range(len(df)), 10)
random_rows = df.loc[random_indices]

# Display the selected random rows
print(random_rows)

# print the first five rows of the data
# print(df.head())

# split the data into training and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# split the data into k folds for cross validation
num_folds = 10
skf = StratifiedKFold(n_splits=num_folds, shuffle=True, random_state=42)

# scale the data
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# train the logistic regression model
# default solver=libliner, here we are using lbgfs=Limited-memory Broyden-Fletcher-Goldfarb-Shannon optimization algorithm
# this gonna effect how the model is trained and converges to the optimal coefficients(weight) during training
# lbgfs uses second order derivation of the loss function
# its a good choice if the number of featrues are not extremely high and the dataset is relatively large
# it perform well for multi-class classification problems and is the default solver for logistic regression multi-class classification problems
model_log_reg = LogisticRegression(max_iter=1000,
                                   solver='lbfgs',
                                   multi_class='multinomial')  # logistic regression model using the LBFGS optimization algorithm did not converge within the specified number of iterations.
model_log_reg.fit(X_train_scaled, y_train)

# make predictions for the test set
y_pred = model_log_reg.predict(X_test_scaled)

# Predict class probabilities for the test data
y_probs = model_log_reg.predict_proba(X_test_scaled)

# calculate the accuracy score
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy:.2f}")

# cross validation without kFold
accuracies = cross_val_score(model_log_reg, X_train_scaled, y_train, cv=10)
print(f"Accuracy: {accuracies.mean():.2f} +/- {accuracies.std():.2f}")

# perform cross validation with kFold and with non Scales X data and y target labels
cross_val_scores = cross_val_score(model_log_reg, X, y, cv=skf,
                                   scoring='accuracy')  # we didnt scale the X data, because the linear regression model using the liblinear model doesnt necessarily require feature scaling

# iterate over the cross validation scores using enumerate
for fold_idx, accuracy in enumerate(cross_val_scores):
    print(f"Fold {fold_idx + 1} Accuracy: {accuracy:.2f}")

print()

# hyperparameter tuning using grid search
from sklearn.model_selection import GridSearchCV

# Define the hyperparameter grid
param_grid = {'C': [0.001, 0.01, 0.1, 1, 10, 100], 'max_iter': [100, 200, 300]}

# Perform grid search
grid_search = GridSearchCV(model_log_reg, param_grid, cv=5, scoring='accuracy')
grid_search.fit(X_train_scaled, y_train)

# Get the best hyperparameters and score
best_params = grid_search.best_params_
best_score = grid_search.best_score_

print("Best Hyperparameters:", best_params)
print("Best Score:", best_score)

# calculate the correlation matrix
corr_matrix = df.corr()

# plot the correlation matrix
import seaborn as sns

sns.heatmap(corr_matrix, annot=True, cmap='coolwarm')
# Add interpretation annotations
plt.text(0.5, -0.3, "Interpretation:", ha="center", fontsize=12, fontweight="bold")
plt.text(0.5, -0.5, "- A positive correlation value indicates that when one feature increases,", ha="left", fontsize=10)
plt.text(0.5, -0.6, "the other tends to increase as well.", ha="left", fontsize=10)
plt.text(0.5, -0.8, "- A negative correlation value indicates that when one feature increases,", ha="left", fontsize=10)
plt.text(0.5, -0.9, "the other tends to decrease.", ha="left", fontsize=10)
plt.text(0.5, -1.1, "- A value close to 0 indicates a weak or no linear correlation between the features.", ha="left",
         fontsize=10)
plt.text(0.5, -1.3,
         "- The diagonal elements have a correlation of 1, as they represent the correlation of a feature with itself.",
         ha="left", fontsize=10)

plt.title("Correlation Heatmap")
plt.show()

'''
This code creates scatter plots between pairs of features in the Iris dataset, using different colors and markers for each species (target label). 
The pairplot function from seaborn is used to create the scatter plots, and the hue parameter is set to "Species" to indicate that we want to color the points based on the species label. 
The markers parameter specifies different markers for each species.

The resulting scatter plots provide visual insights into the relationships between pairs of features while considering 
the target labels (species) as different colors.
'''
# create scatter plots for pairs of features and target labels
sns.set(style='ticks')
sns.pairplot(df, hue="Target", markers=["o", "s", "D"])
plt.suptitle("Pairwise Scatter Plots with Target Labels")
plt.show()

# Create box plots
plt.figure(figsize=(10, 6))
sns.boxplot(x='Target', y='sepal length (cm)', data=df)
plt.suptitle("Box Plot of Sepal Length for Different Species")
plt.show()

# violin plot
plt.figure(figsize=(10, 6))
sns.violinplot(x='Target', y='sepal length (cm)', data=df)
plt.suptitle("Violin Plot of Sepal Length for Different Species")
plt.show()

# count plot
plt.figure(figsize=(8, 6))
sns.countplot(x='Target', data=df)
plt.suptitle("Count Plot of Species")
plt.show()

# Calculate the count of each species
species_counts = [sum(y == i) for i in range(len(class_names))]

# Create a pie chart
plt.figure(figsize=(6, 6))
plt.pie(species_counts, labels=class_names, autopct='%1.1f%%', startangle=140,
        colors=['skyblue', 'lightgreen', 'lightcoral'])
plt.suptitle("Distribution of Species in Iris Dataset")
plt.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.

# Show the plot
plt.show()


# Compute the logistic regression loss (negative log-likelihood) for the test data
def logistic_loss(X, y, model):
    probabilities = model.predict_proba(X)[:, 1]
    loss = -np.mean(y * np.log(probabilities) + (1 - y) * np.log(1 - probabilities))
    return loss


test_loss = logistic_loss(X_test_scaled, y_test, model_log_reg)
print("Test Loss (Negative Log-Likelihood):", test_loss)


def interpret_loss(loss_value):
    if loss_value < 1:
        interpretation = "Excellent: The model's predictions are very close to the actual outcomes."
    elif loss_value < 2:
        interpretation = "Good: The model's predictions are fairly accurate, but there is room for improvement"
    elif loss_value < 3:
        interpretation = "Fair: The model's predictions are moderately aligned with the actual outcomes"
    else:
        interpretation = "Needs Improvement: The model's predictions have a significant deviation from the actual outcomes and require improvement."

    return interpretation


interpretation = interpret_loss(test_loss)
print("Interpretation of Test Loss:", interpretation)


def method_name():
    global interpretation
    # Compute the cross-entropy loss using scikit-learn's log_loss function
    cross_entropy_loss = log_loss(y_test, y_probs)
    print("Cross-Entropy Loss:", cross_entropy_loss)
    interpretation = interpret_loss(cross_entropy_loss)
    print("Interpretation of Test Loss:", interpretation)


method_name()
