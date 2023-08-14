import random
import numpy as np
import pandas as pd
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold, GridSearchCV
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, log_loss
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier


def load_iris_data():
    iris = load_iris()
    X = iris.data
    y = iris.target
    feature_names = iris.feature_names
    class_names = iris.target_names
    # print the feature names and class names
    print(feature_names)
    print(class_names)

    return X, y, feature_names, class_names


def create_dataframe(X, y, feature_names, class_names):
    df = pd.DataFrame(X, columns=feature_names)
    df['Target'] = [class_names[i] for i in y]
    return df


def select_random_rows(df, num_rows=10):
    random.seed(42)
    random_indices = random.sample(range(len(df)), num_rows)
    random_rows = df.loc[random_indices]
    # Display the selected random rows
    print(random_rows)
    return random_rows


def preprocess_data(X_train, X_test):
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    return X_train_scaled, X_test_scaled


def train_model(X_train_scaled, y_train):
    model_log_reg = LogisticRegression(max_iter=1000, solver='lbfgs', multi_class='multinomial')
    model_log_reg.fit(X_train_scaled, y_train)
    return model_log_reg


def evaluate_model(X_test_scaled, y_test, model):
    y_pred = model.predict(X_test_scaled)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Accuracy: {accuracy:.2f}")
    return accuracy


def perform_cross_validation(X_train_scaled, y_train, skf):
    model_log_reg = LogisticRegression(max_iter=1000, solver='lbfgs', multi_class='multinomial')
    cross_val_scores = cross_val_score(model_log_reg, X_train_scaled, y_train, cv=skf)
    # iterate over the cross validation scores using enumerate
    for fold_idx, accuracy in enumerate(cross_val_scores):
        print(f"Fold {fold_idx + 1} Accuracy: {accuracy:.2f}")
    return cross_val_scores


def tune_hyperparameters(X_train_scaled, y_train):
    param_grid = {'C': [0.001, 0.01, 0.1, 1, 10, 100], 'max_iter': [100, 200, 300]}
    grid_search = GridSearchCV(LogisticRegression(solver='lbfgs', multi_class='multinomial'),
                               param_grid, cv=5, scoring='accuracy')
    grid_search.fit(X_train_scaled, y_train)
    best_params = grid_search.best_params_
    best_score = grid_search.best_score_
    print("Best Hyperparameters:{}, best_score: {}", best_params, best_score)
    return best_params, best_score


def create_correlation_heatmap(data):
    corr_matrix = data.corr()
    plt.figure(figsize=(10, 8))
    sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0, fmt=".2f")
    # Add interpretation annotations
    plt.text(0.5, -0.3, "Interpretation:", ha="center", fontsize=12, fontweight="bold")
    plt.text(0.5, -0.5, "- A positive correlation value indicates that when one feature increases,", ha="left",
             fontsize=10)
    plt.text(0.5, -0.6, "the other tends to increase as well.", ha="left", fontsize=10)
    plt.text(0.5, -0.8, "- A negative correlation value indicates that when one feature increases,", ha="left",
             fontsize=10)
    plt.text(0.5, -0.9, "the other tends to decrease.", ha="left", fontsize=10)
    plt.text(0.5, -1.1, "- A value close to 0 indicates a weak or no linear correlation between the features.",
             ha="left",
             fontsize=10)
    plt.text(0.5, -1.3,
             "- The diagonal elements have a correlation of 1, as they represent the correlation of a feature with itself.",
             ha="left", fontsize=10)
    # Add interpretation annotations here
    plt.title("Correlation Matrix Heatmap")
    plt.show()


def create_pairwise_scatter_plots(df):
    sns.set(style='ticks')
    sns.pairplot(df, hue="Target", markers=["o", "s", "D"])
    plt.suptitle("Pairwise Scatter Plots with Target Labels")
    plt.show()


def create_box_plot(df):
    plt.figure(figsize=(10, 6))
    sns.boxplot(x='Target', y='sepal length (cm)', data=df)
    plt.suptitle("Box Plot of Sepal Length for Different Species")
    plt.show()


def create_violin_plot(df):
    plt.figure(figsize=(10, 6))
    sns.violinplot(x='Target', y='sepal length (cm)', data=df)
    plt.suptitle("Violin Plot of Sepal Length for Different Species")
    plt.show()


def feature_importance(X_train_scaled, y_train, feature_names):
    # Train a Random Forest classifier
    rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
    rf_model.fit(X_train_scaled, y_train)

    # Get feature importances
    feature_importances = rf_model.feature_importances_

    # Create a bar plot of feature importances
    plt.bar(range(len(feature_names)), feature_importances)
    plt.xticks(range(len(feature_names)), feature_names, rotation=45)
    plt.xlabel('Feature')
    plt.ylabel('Importance')
    plt.suptitle('Feature Importance')
    plt.tight_layout()
    plt.show()


def create_count_plot(df):
    plt.figure(figsize=(8, 6))
    sns.countplot(x='Target', data=df)
    plt.suptitle("Count Plot of Species")
    plt.show()


def create_count_plot_pie(y, class_names):
    # Calculate the count of each species
    species_counts = [sum(y == i) for i in range(len(class_names))]

    plt.figure(figsize=(6, 6))
    plt.pie(species_counts, labels=class_names, autopct='%1.1f%%', startangle=140,
            colors=['skyblue', 'lightgreen', 'lightcoral'])
    plt.suptitle("Distribution of Species in Iris Dataset")
    plt.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.

    # Show the plot
    plt.show()


def logistic_loss(X, y, model):
    probabilities = model.predict_proba(X)[:, 1]
    loss = -np.mean(y * np.log(probabilities) + (1 - y) * np.log(1 - probabilities))
    return loss


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


def cross_entropy_loss(y_test, y_probs):
    cross_entropy_loss = log_loss(y_test, y_probs)
    print("Cross-Entropy Loss:", cross_entropy_loss)
    interpretation = interpret_loss(cross_entropy_loss)
    print("Interpretation of Test Loss:", interpretation)


def main():
    X, y, feature_names, class_names = load_iris_data()
    df = create_dataframe(X, y, feature_names, class_names)
    random_rows = select_random_rows(df)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    num_folds = 10
    skf = StratifiedKFold(n_splits=num_folds, shuffle=True, random_state=42)
    X_train_scaled, X_test_scaled = preprocess_data(X_train, X_test)
    model = train_model(X_train_scaled, y_train)
    accuracy = evaluate_model(X_test_scaled, y_test, model)
    cross_val_scores = perform_cross_validation(X_train_scaled, y_train, skf)
    best_params, best_score = tune_hyperparameters(X_train_scaled, y_train)

    create_count_plot(df)
    create_count_plot_pie(y, class_names)
    create_correlation_heatmap(df)
    create_pairwise_scatter_plots(df)
    create_box_plot(df)
    create_violin_plot(df)
    feature_importance(X_train_scaled, y_train, feature_names)

    test_loss = logistic_loss(X_test_scaled, y_test, model)
    interpretation = interpret_loss(test_loss)
    print("Interpretation of Test Loss:", interpretation)
    cross_entropy_loss(y_test, model.predict_proba(X_test_scaled))


if __name__ == "__main__":
    main()
