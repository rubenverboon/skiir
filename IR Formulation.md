My idea for the score of an article would be as follows:

``` 
Sa = SUM( Ria * Rib * p * SCSi ) 
```  
With `Sa` = Score of article
`Ria` = Relevance of term `i` in article `a`
`Rib` = Relevance of term `i` in article `b` 
`p` = Multiplier for term being in 'selected' paragraph
`SCSi` = SCS score of term `i` with respect to selected term(s).

Some edge cases:  
* `SCSi` = 1 for two selected terms
* `SCSi` = `SCSi1` * `SCSi2` * ... * `SCSin` for multiple selected terms.
* `SCSi` = `(SCSi * 0.6) + 0.4` to not make it super-influential if no relations are found in 2 steps.

In SQL, this can be done in two ways:
* Create a `FOR` loop, looping over terms
* Cross-join the mediating relation table of Entities and Articles with itself and calculate.

Either can be done, the difference is probably in performance. It seems the loop would be a bit quicker, but I've no proof.

Method 1:
```
@ArtId = ID of article with requested text
@InParagraph = Array with entities in 'selected' paragraph
#SCS = Table with SCS scores of all non-selected entities

CREATE TABLE #tempCalc(
  id, ArtId, Score
)

INSERT INTO #tempCalc(id, ArtId, Score)
  (
   SELECT newid, C.ArtId, 0
   FROM Cross AS C
   WHERE C.TermId IN (
     SELECT C1.TermId 
     FROM Cross AS C1
     WHERE C1.ArtId = @ArtId
     )
  ) 

FOR t IN SELECT TermId 
	 FROM Cross
	 WHERE ArtId = @ArtId
LOOP

  UPDATE #tempCalc
  SET Score = 
   Score + 
     (SELECT C.Relevance
      FROM Cross AS C
      WHERE C.TermId = t
      AND   C.ArtId  = #tempCalc.ArtId
     ) *
     (SELECT SELECT C.Relevance
      FROM Cross AS C
      WHERE C.TermId = t
      AND   C.ArtId  = @ArtId
     ) *
     (IF t = ANY(@InParagraph) THEN 1 ELSE 0.5)
     * 
     (SELECT SCScore FROM #SCS WHERE TermId = t)
   
   RETURN NEXT t;
END LOOP;

SELECT TOP 4 ArtId 
FROM #tempCalc
SORT BY Score DESC
```

**Outdated**
Method 2:  
```
SELECT ArtId, 
  SUM(
   SELECT C1.Relevance * C2.Relevance * (IF C1.TID IN @SelectedTerms THEN 1 ELSE 0.5 END IF)
   FROM   Cross AS C1
   LEFT JOIN Cross AS C2 ON C1.TID = C2.TID
   WHERE C1.AID = @ArtId
   AND C1.AID <> C2.AID
  ) AS Score
```


!! Haven't tested the code yet, since I don't have Postgres here. Will check later. I believe the first query exists already, made by @rubenverboon .
