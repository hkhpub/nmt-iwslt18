import numpy as np
np.random.seed(1)

DATA_PREFIX = '/hdd/data/iwslt18/open-subtitles18/data.raw/OpenSubtitles2018.en-eu'
OUT_DIR = "/hdd/data/iwslt18/open-subtitles18/data.raw"

DEV_NUM = 4000
TEST_NUM = 1000

eu_file = open((DATA_PREFIX+".eu"), "r")
en_file = open((DATA_PREFIX+".en"), "r")

eu_list = eu_file.readlines()
en_list = en_file.readlines()
total_num = len(eu_list)
dev_test_indices = np.random.choice(total_num, DEV_NUM+TEST_NUM, replace=False)
dev_indexes = dev_test_indices[:DEV_NUM]
test_indexes = dev_test_indices[DEV_NUM:]

# write file
train_eu = open((OUT_DIR+"/train.eu"), "w")
train_en = open((OUT_DIR+"/train.en"), "w")
dev_eu = open((OUT_DIR+"/dev.eu"), "w")
dev_en = open((OUT_DIR+"/dev.en"), "w")
test_eu = open((OUT_DIR+"/test.eu"), "w")
test_en = open((OUT_DIR+"/test.en"), "w")

for i, (eu_line, en_line) in enumerate(zip(eu_list, en_list)):
    if i in dev_indexes:
        # dev
        dev_eu.write(eu_line)
        dev_en.write(en_line)

    elif i in test_indexes:
        # test
        test_eu.write(eu_line)
        test_en.write(en_line)

    else:
        # train
        train_eu.write(eu_line)
        train_en.write(en_line)

train_eu.close()
train_en.close()
dev_eu.close()
dev_en.close()
test_eu.close()
test_en.close()
eu_file.close()
en_file.close()
