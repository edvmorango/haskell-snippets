module Exercises where
  
import Test.Hspec  
import Test.QuickCheck.Arbitrary
import Test.QuickCheck.Checkers 
import Test.QuickCheck.Classes
import Test.QuickCheck
import Data.Monoid
  

genT :: (Arbitrary a, Eq a, Ord a, Monoid a) => Gen a
genT = do
  a <- arbitrary
  return a

genTAx = genT :: Gen (Product Int)
  
--------------------------------------------------------------------------------
  
data Constant a b = Constant b deriving (Eq, Show)

instance (Monoid b) => Monoid (Constant a b) where
  mempty = Constant (mempty)
  mappend (Constant b) (Constant b') = Constant (b `mappend` b')

instance Foldable (Constant a) where
  foldr f acc (Constant c) = f c acc
  foldl f acc (Constant c) = f acc c
  foldMap f (Constant c) = f c

genConstant :: (Arbitrary a, Arbitrary b, Monoid b) => Gen (Constant a b) 
genConstant = do
    b <- arbitrary
    return $ Constant b

genConstants :: (Arbitrary a, Arbitrary b, Monoid b) => Gen b -> Gen ([(Constant a b)], [b])
genConstants g = do
    l <- listOf g
    return $ ( (fmap (Constant) l), l)

instance (Arbitrary a, Arbitrary b, Monoid b) => Arbitrary (Constant a b) where
  arbitrary = genConstant
  
instance (Eq a, Eq b) => EqProp (Constant a b) where
  (=-=) = eq

--------------------------------------------------------------------------------

data Two a b = Two a b  deriving (Eq, Show)

instance (Monoid a, Monoid b) => Monoid (Two a b) where
  mempty = Two (mempty) (mempty)
  mappend (Two a b) (Two a' b') = Two (a `mappend` a') (b `mappend` b')

instance Foldable (Two a) where
  foldr f acc (Two _ c) = f c acc
  foldl f acc (Two _ c) = f acc c
  foldMap f (Two _ c) = f c

instance (Arbitrary a, Arbitrary b, Monoid a, Monoid b) => Arbitrary (Two a b) where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    return $ Two a b
    
instance (Eq a, Eq b) => EqProp (Two a b) where
  (=-=) = eq

genTwos :: (Arbitrary a, Arbitrary b, Monoid a, Monoid b) 
            => Gen a 
            -> Gen b 
            -> Gen ([(Two a b)], [(a,b)])

genTwos ga gb = do 
  la <- listOf ga
  lb <- listOf gb
  let l = zip la lb in
    return $ ( fmap (\(a,b) -> Two a b) l, l)


genTwoAx = 
  (genTwos  genTAx genTAx) :: (Gen ([Two (Product Int) (Product Int)], [((Product Int), (Product Int))]))

  
--------------------------------------------------------------------------------

data Three a b c = Three b c deriving (Eq, Show)

instance (Monoid b, Monoid c) => Monoid (Three a b c) where
  mempty = Three (mempty) (mempty)
  mappend (Three b c) (Three b' c') = Three (b `mappend` b') (c `mappend` c')

instance Foldable (Three a b) where
  foldr f acc (Three _ c) = f c acc
  foldl f acc (Three _ c) = f acc c
  foldMap f (Three _ c) = f c
  
  
instance (Arbitrary b, Arbitrary c, Monoid b, Monoid c) => Arbitrary (Three a b c) where
  arbitrary = do
    b <- arbitrary
    c <- arbitrary
    return $ Three b c
    
instance (Eq b, Eq c) => EqProp (Three a b c) where
  (=-=) = eq

genThrees :: (Arbitrary b, Arbitrary c, Monoid b, Monoid c) 
            => Gen b
            -> Gen c 
            -> Gen ([(Three a b c)], [(b,c)])    
genThrees gb gc = do 
  la <- listOf gb
  lc <- listOf gc
  let l = zip la lc in
    return $ ( fmap (\(b, c) -> Three b c) l, l)


genThreeAx = 
  (genThrees genTAx genTAx) :: (Gen ([Three Int (Product Int) (Product Int)], [((Product Int), (Product Int))]))

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------





data Three' a b = Three' a b b deriving (Eq, Show)

data Four a b = Four a b b b  deriving (Eq, Show)


type PhantomType = ( () , () ,())
type LeftMonoid = (String, String, String)
type TestType = (String, Sum Int, Product Int)

tests :: IO()
tests = hspec $ do
  describe "Constant" $ do
      it "Constant monoid" $ do
        quickBatch $ monoid ( Constant ("Hey", Sum 20, Product 10 ) :: Constant PhantomType TestType  )
      it "foldr == foldMap" $ do 
        forAll ( (genConstants (genT :: Gen (Product Int)) ) :: Gen ([Constant Int (Product Int)], [Product Int])) 
                (\(w, u) -> foldr (\c ac -> (mappend c ac)) (Constant (Product 1)) w == foldMap (Constant) u   ) 
  describe "Two " $ do
      it "Two monoid" $ do
        quickBatch $ monoid ( Two ("a", "b", "c") ("Hey", Sum 20, Product 10 ) :: Two LeftMonoid TestType  )
      it "foldr == foldMap" $ do 
        forAll ( genTwoAx) 
                (\(w, u) -> foldr (\a ac -> mappend a ac) (Two (Product 1) (Product 1) ) w == foldMap (\(a,b) -> Two a b) u   )               
  describe "Three " $ do
      it "Three monoid" $ do
        quickBatch $ monoid ( Three ("a", "b", "c") ("Hey", Sum 20, Product 10 ) :: Three Int LeftMonoid TestType  )
      it "foldr == foldMap" $ do 
        forAll ( genThreeAx) 
                (\(w, u) -> foldr (\a ac -> mappend a ac) (Three (Product 1) (Product 1) ) w == foldMap (\(a,b) -> Three a b) u   ) 
            
                
                
                
