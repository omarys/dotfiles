import requests

from requests.adapters import HTTPAdapter, Retry


def main():
    """
    This piece of code was created in about 2 minutes to test a massive blob of
    RSS feeds that were copied from online sources.  I plan to pipe this to a file,
    and "tail -f" that file when running it.  Wordpress will give a lot of false
    positive results, but there are cases where someone deletes their blog, or
    puts it behind a paywall, so they still have to be checked.  Annoying, I know.
    """
    s = requests.Session()
    s.mount(
        "http://", HTTPAdapter(max_retries=Retry(total=1))
    )  # Limit retries to 1, because we don't want to DDOS anybody.

    with open("urls") as url_file:
        """
        lines is utilized to skip ahead when a link breaks halfway down the file
        replace 0 with where process previously failed, and voila!
        """
        lines = url_file.readlines()[0:]
        for line in lines:
            # A typical line in the file looks like this:
            # http://arne-mertz.de/feed/ "~Simplify C++" programming c++
            # So we split on the first space, and take that first element
            link = line.split(" ", 1)[0]
            try:
                s.get(link)
                # "if s" is supposed to be true for STATUS_OK
                if not s:
                    print(f"{link} appears to be a broken link.")
            except Exception as ex:
                print(f"{ex} encountered when attempting to access {link}.")
                continue


if __name__ == "__main__":
    main()
