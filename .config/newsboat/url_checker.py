import requests

from requests.adapters import HTTPAdapter, Retry


def main():
    """
    This piece of code was created in about 2 minutes to test a massive blob of
    RSS feeds that copied from online sources.  I always pipe this to a file,
    and "tail -f" that file when running it.  Wordpress will give a lot of false
    positive results, but there are cases where someone deletes their blog, or
    puts it behind a paywall, they still have to be checked.  Annoying, I know.
    """
    s = requests.Session()
    s.mount(
        "http://", HTTPAdapter(max_retries=Retry(total=1))
    )  # Don't want to DDOS anybody.

    with open("urls") as url_file:
        """
        lines is utilized to skip ahead when a link breaks halfway down the file
        replace 0 with where process previously failed, and voila!
        """
        lines = url_file.readlines()[0:]
        for line in lines:
            link = line.split(" ", 1)[0]
            try:
                s.get(link)
                if not s:
                    print(f"{link} appears to be a broken link.")
            except Exception as ex:
                print(f"{ex} encountered when attempting to access {link}.")
                continue


if __name__ == "__main__":
    main()
