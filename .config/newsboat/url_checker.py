import requests

from requests.adapters import HTTPAdapter, Retry


def main():
    s = requests.Session()

    retries = Retry(total=1)

    s.mount("http://", HTTPAdapter(max_retries=retries))

    with open("urls") as url_file:
        """
        lines is utilized to skip ahead when a link breaks halfway down the file
        """
        lines = url_file.readlines()[507:]
        for line in lines:
            link = line.split(" ", 1)[0]
            try:
                s.get(link)
                print(f"Testing {link} now...")
                if not s:
                    print(f"{link} appears to be a broken link.")
            except Exception as ex:
                print(f"Encountered {ex} exception when attempting to access {link}.")
                continue


if __name__ == "__main__":
    main()
