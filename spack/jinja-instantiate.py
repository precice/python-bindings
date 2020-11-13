import jinja2
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--branch', type=str, help="Branch to be checked out", default="develop")
args = parser.parse_args()

f = open("var/spack/repos/builtin/packages/py-pyprecice/package.py", "r")

template = jinja2.Template(f.read())
print(template.render(branch=args.branch))