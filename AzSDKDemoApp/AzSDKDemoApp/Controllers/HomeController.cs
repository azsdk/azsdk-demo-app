using System.Web.Mvc;
using AzSDKDemoApp.Helpers;

namespace AzSDKDemoApp.Controllers
{
	public class HomeController : Controller
	{
		public ActionResult Index()
		{
			ViewBag.ImageUrl = StorageHelpers.GetUrlForBlobImage();
			return View();
		}
	}
}