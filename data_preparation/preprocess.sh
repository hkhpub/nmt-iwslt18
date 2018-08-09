IWSLT18_DIR=/hdd/data/iwslt18/raw
TARGET_DIR=/hdd/data/iwslt18/target
MAX_SEN_LEN=50

SCRIPT_DIR=/home/hkh/sources/tf-iwslt18/data_preparation
MOSES_SCRIPT=$SCRIPT_DIR/mosesdecoder-RELEASE-2.1.1/scripts
WAT_SCRIPT=$SCRIPT_DIR/script.segmentation.distribution

# Download Moses-2.1.1 & scripts from ASPEC page
cd $SCRIPT_DIR
if [ ! -d mosesdecoder-RELEASE-2.1.1 ]
then
    wget https://github.com/moses-smt/mosesdecoder/archive/RELEASE-2.1.1.zip
    unzip RELEASE-2.1.1
fi
if [ ! -d script.segmentation.distribution ]
then
    wget wget http://lotus.kuee.kyoto-u.ac.jp/WAT/evaluation/automatic_evaluation_systems/script.segmentation.distribution.tar.gz
    tar zxvf script.segmentation.distribution.tar.gz
fi
rm RELEASE-2.1.1.zip script.segmentation.distribution.tar.gz 2>/dev/null

# Copy data into corpus.org
mkdir $TARGET_DIR $TARGET_DIR/corpus.org 2>/dev/null
cd $TARGET_DIR
cp $IWSLT18_DIR/train/train.clean.* corpus.org
cp $IWSLT18_DIR/dev/dev.clean.* corpus.org

cd $TARGET_DIR
mkdir corpus.tok
cd corpus.tok

# Tokenize English data
for file in train dev; do
  cat ../corpus.org/${file}.clean.en | \
    perl ${WAT_SCRIPT}/z2h-utf8.pl | \
    perl ${MOSES_SCRIPT}/tokenizer/tokenizer.perl -l en \
    > ${file}.tok.en &
done; wait

# Tokenize Basque data
for file in train dev; do
  cat ../corpus.org/${file}.clean.eu | \
    perl ${WAT_SCRIPT}/z2h-utf8.pl | \
    perl ${MOSES_SCRIPT}/tokenizer/tokenizer.perl -l eu \
    > ${file}.tok.eu &
done; wait

# Train truecaser for English
cat train.tok.en dev.tok.en > train_dev.tok.en
${MOSES_SCRIPT}/recaser/train-truecaser.perl --model truecase-model.en --corpus train_dev.tok.en

# Truecase English data
for file in train dev; do
    ${MOSES_SCRIPT}/recaser/truecase.perl --model truecase-model.en < ${file}.tok.en > ${file}.en &
done; wait

# Train truecaser for Basque
cat train.tok.eu dev.tok.eu > train_dev.tok.eu
${MOSES_SCRIPT}/recaser/train-truecaser.perl --model truecase-model.eu --corpus train_dev.tok.eu

# Truecase Basque data
for file in train dev; do
    ${MOSES_SCRIPT}/recaser/truecase.perl --model truecase-model.eu < ${file}.tok.eu > ${file}.eu &
done; wait

# Clean training data
cd $TARGET_DIR/corpus.tok
for file in train; do
    perl ${MOSES_SCRIPT}/training/clean-corpus-n.perl ${file} eu en ${file}_cleaned 1 $MAX_SEN_LEN &
done; wait

cd $TARGET_DIR
mkdir corpus.baseline corpus.baseline/train corpus.baseline/dev corpus.baseline/test corpus.baseline/vocab
cd $TARGET_DIR/corpus.tok
cat train_cleaned.en > $TARGET_DIR/corpus.baseline/train/train.en &
cat train_cleaned.eu > $TARGET_DIR/corpus.baseline/train/train.eu &
wait

# Copy dev and test data
for file in dev; do
    cp $TARGET_DIR/corpus.tok/${file}.en $TARGET_DIR/corpus.baseline/${file}/${file}.en &
    cp $TARGET_DIR/corpus.tok/${file}.eu $TARGET_DIR/corpus.baseline/${file}/${file}.eu &
done; wait

# Make vocab file
for lang in eu en; do
    python $SCRIPT_DIR/make_vocab.py < $TARGET_DIR/corpus.baseline/train/train.$lang > $TARGET_DIR/corpus.baseline/vocab/all.$lang &
done; wait
