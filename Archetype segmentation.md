# Archetype Analysis

Archetypal analysis is a method for analyzing and understanding the heterogeneity of consumers (or products) in a market. The technique is well established in the
physical science and mathematics, but was only introduced to the field of marketing research in 1998.

Mass marketing is one extreme: everyone is offered the same product(s), the same advertising and promotion, the same distribution
channels, the same prices. More sophisticated marketers employ market segmentation where consumers are divided into two or more classes with a different
marketing mix for each class. 

Using segmentation research, a marketer can:
• Estimate the size of each segment and its share of category volume
• Select one or more segments to target
• Create a marketing mix tailored to each target segment 

![image](https://user-images.githubusercontent.com/9406665/36064148-7f619e86-0eac-11e8-9db6-c58cb818b514.png)

Each dot is a consumer. There are three obvious segments here, so those within a certain distance of the mid-point of each segment are assigned to that segment (the
red circles).

# Archetypal Analysis: An Alternative Paradigm
Archetypal analysis is an alternative to traditional segmentation for understanding consumer heterogeneity.
• Segmentation (at least when based on statistical cluster analysis) makes the implicit assumption that there are several "average" consumers. They are
found in the dead center, statistically speaking, of each cluster.
• Archetypal analysis assumes instead that there are several "pure" consumers who are on the "edges" of the data. All others are considered to be mixtures
of these pure types.

### Application of Archetypal Analysis
Since the procedure is quite new to marketing research, its applications are not fully developed. At the very least, archetypal analysis is appropriate:
• In categories where the archetypes are likely to be aspirational in nature.
o Whether a category is aspirational is a matter of judgment, not something that archeypal analysis can tell you
o The goal would be to aim messages at what consumers want to be, not what they are.
• In categories where the extreme types of consumer are the trend-setters
o Speak to them and the others will follow


Given is an n × m matrix X representing a multivariate data set with n observations and m attributes. For a given k the archetypal analysis finds the matrix Z of k m-dimensional archetypes according to the two fundamentals:
(1) The data are best approximated by convex combinations of the archetypes, i.e., they minimize
(2) The archetypes are convex combinations of the data points:

With a view to the implementation, the algorithm consists of the following steps:
Given the number of archetypes k:
1. Data preparation and initialization: scale data, add a dummy row (see below) and initialize in a way that the the constraints are fulfilled to calculate the starting archetypes Z.
2. Loop until RSS reduction is sufficiently small or the number of maximum iterations is reached:

2.1. Find best alpha for the given set of archetypes Z: solve n convex least squares problems
(i = 1, . . . , n)

2.2. Recalculate archetypes : solve system of linear equations.
2.3. Find best beta for the given set of archetypes ˜ Z: solve k convex least squares problems
(j = 1, . . . , k)
2.4. Recalculate archetypes Z.
2.5. Calculate residual sum of squares RSS.
3. Post-processing: remove dummy row and rescale archetypes.

