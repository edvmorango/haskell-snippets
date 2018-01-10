module MonoidsFinal where

import Test.QuickCheck
import Test.Hspec
import Data.Monoid
import qualified Data.Semigroup as S


semigroupAssoc :: (Eq a, Monoid a) => a -> a -> a -> Bool
semigroupAssoc a b c =  a <> (b <> c) == (a <> b) <> c

monoidRightIdentity :: (Eq a, Monoid a) => a -> Bool
monoidRightIdentity a = (a <> mempty) == a

monoidLeftIdentity :: (Eq a, Monoid a) => a -> Bool
monoidLeftIdentity a = (mempty <> a) == a



-----------------------------------------

data Trivial = Trivial deriving (Eq, Show)

instance Arbitrary Trivial where
  arbitrary = return Trivial

instance S.Semigroup Trivial where
  _ <> _ = Trivial

instance Monoid Trivial where
   mempty = Trivial
   mappend = (S.<>)

type TrivAssoc = Trivial -> Trivial -> Trivial -> Bool

-----------------------------------------

data Identity a = Identity a deriving (Eq, Show)

instance (Arbitrary a, S.Semigroup a, Monoid a) => Arbitrary (Identity a) where
  arbitrary = do
    a <- arbitrary
    return $ Identity a

instance (S.Semigroup a) => S.Semigroup (Identity a) where
  (Identity a) <> (Identity a') = Identity ( a S.<> a')

instance (Monoid a, S.Semigroup a) => Monoid (Identity a) where
   mempty = (Identity mempty)
   mappend = (S.<>)

type IdentityAssoc a = (Identity a) -> (Identity a) -> (Identity a) -> Bool


-----------------------------------------
data Two a b = Two a b deriving (Eq, Show)

instance (Arbitrary a
        , Arbitrary b
        , S.Semigroup a
        , S.Semigroup b
        , Monoid a
        , Monoid b) => Arbitrary (Two a b) where
   arbitrary = do
     a <- arbitrary
     b <- arbitrary
     return $ Two a b


instance (S.Semigroup a, S.Semigroup b) => S.Semigroup (Two a b) where
  (Two a b) <> (Two a' b') = Two (a S.<> a') (b S.<> b')

instance (Monoid a, S.Semigroup a, Monoid b,  S.Semigroup b) => Monoid (Two a b) where
  mempty = Two mempty mempty
  mappend = (S.<>)

type TwoAssoc a b = (Two a b) -> (Two a b) -> (Two a b) -> Bool

-------------------------------------------

tests :: IO ()
tests = hspec $ do
  describe "Trivial" $ do
    it "Trivial assoc" $ do
      quickCheck (semigroupAssoc :: TrivAssoc)
    it "Trivial rid" $ do
      quickCheck (monoidLeftIdentity :: Trivial -> Bool)
    it "Trivial lid" $ do
      quickCheck (monoidRightIdentity :: Trivial -> Bool)
  describe "Identity" $ do
    it "Identity assoc" $ do
      quickCheck (semigroupAssoc :: (IdentityAssoc String))
    it "Identity rid" $ do
      quickCheck (monoidLeftIdentity :: (Identity (Sum Int)) -> Bool)
    it "Identity lid" $ do
      quickCheck (monoidRightIdentity :: (Identity (Sum Int))  -> Bool)
  describe "Two" $ do
    it "Two assoc" $ do
      quickCheck (semigroupAssoc :: (TwoAssoc String (Sum Int) ))
    it "Two rid" $ do
      quickCheck (monoidLeftIdentity :: (Two String (Sum Int)) -> Bool)
    it "Two lid" $ do
      quickCheck (monoidRightIdentity :: (Two String (Sum Int))  -> Bool)