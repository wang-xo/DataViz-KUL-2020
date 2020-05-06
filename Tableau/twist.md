## Twisting the Term Frequency

To avoid some irrelevant words, I did this with Tableau calculated fields.

For each of the 15 genres, I get the **Number of Tracks with the target Word** and divide this by the **Total Number of Tracks in the Genre**. Call this "Word Popularity".
```
{FIXED [majority-genre],[word_m]: COUNT([word_m])}
/{FIXED [majority-genre]: COUNTD([trackId])}
```
Then, I compare this popularity (of 1 genre) with the average (of the 15 genres). If it is above the average, then I keep the difference from the average. If it is below the average, I assign 0. Call this "Over avg Popularity".
```
IF	[Word Popularity] 
		> {FIXED [word_m]: SUM([Word Popularity])}/15

THEN [Word Popularity]
		- {FIXED [word_m]: SUM([Word Popularity])}/15
ELSE 0
END
```
