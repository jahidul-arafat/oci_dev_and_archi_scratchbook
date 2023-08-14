import seaborn as sns
import matplotlib.pyplot as plt

# Load sample data from Seaborn
data = sns.load_dataset("tips")

# Create a histogram using Seaborn
sns.histplot(data=data, x="total_bill", bins=20, kde=True)

# Set plot title and labels
plt.title("Histogram of Total Bill")
plt.xlabel("Total Bill")
plt.ylabel("Frequency")

# Show the plot
plt.show()
