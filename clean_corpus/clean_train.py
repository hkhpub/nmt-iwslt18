from argparse import ArgumentParser


def parse_args():
    p = ArgumentParser('Remove meta tags from iwslt18 train files')
    p.add_argument(
        '--input',
        type=str, metavar='FILE', required=True, help='raw corpus file')
    p.add_argument(
        '--output',
        type=str, metavar='FILE', required=True, help='cleaned corpus file')

    return p.parse_args()


if __name__ == '__main__':
    args = parse_args()

    wf = open(args.output, "w")
    with open(args.input, "r") as f:
        for line in f.readlines():
            if not line.startswith("<"):
                wf.write(line)
    wf.close()
